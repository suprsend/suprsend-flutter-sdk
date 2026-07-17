package com.suprsend.suprsend_flutter_sdk

import android.util.Log
import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.annotation.NonNull
import app.suprsend.AppInfo
import app.suprsend.ClientInfo
import app.suprsend.RefreshUserTokenCallback
import app.suprsend.SuprSend
import app.suprsend.log.LogLevel
import app.suprsend.model.ApiResponse
import app.suprsend.model.ResponseStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONObject
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class SuprsendFlutterSdkPlugin : FlutterPlugin, MethodCallHandler {

  private lateinit var channel: MethodChannel
  private lateinit var context: Context

  private val executor = Executors.newSingleThreadExecutor()
  private val mainHandler = Handler(Looper.getMainLooper())

  // Latest user token, so the native RefreshUserTokenCallback (which only receives
  // the distinctId) can pass the expiring token to Dart like iOS does.
  @Volatile
  private var currentUserToken: String? = null

  companion object {
    // Max time to wait for the Dart refreshUserToken callback to return a token.
    private const val REFRESH_TOKEN_TIMEOUT_SECONDS = 30L
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    context = binding.applicationContext
    channel = MethodChannel(binding.binaryMessenger, "suprsend_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "configure" -> configure(call, result)
      "enableLogging" -> enableLogging(result)
      "isIdentified" -> isIdentified(call, result)
      "getDistinctId" -> getDistinctId(result)
      // iOS-only helpers: no-op on Android (FCM uses setAndroidFcmPush).
      "registerForPush",
      "updatePushSubscription",
      "removePushSubscription" -> result.success(successMap())
      // No-op until the Android native SDK exposes a remove-FCM-token method.
      "removeAndroidFcmPush" -> result.success(successMap())
      "identify",
      "reset",
      "track",
      "set",
      "setOnce",
      "increment",
      "append",
      "remove",
      "unset",
      "addEmail",
      "removeEmail",
      "addSms",
      "removeSms",
      "addWhatsapp",
      "removeWhatsapp",
      "setPreferredLanguage",
      "setTimezone",
      "setAndroidFcmPush" -> runAsync(call, result)
      else -> result.notImplemented()
    }
  }

  private fun configure(call: MethodCall, result: Result) {
    val publicKey = call.argument<String>("publicKey")
    if (publicKey.isNullOrBlank()) {
      result.error("invalid_argument", "publicKey cannot be empty", null)
      return
    }
    val host = call.argument<String>("host")
    val appName = call.argument<String>("appName")
    val appVersion = call.argument<String>("appVersion")
    val appInfo =
      if (!appName.isNullOrBlank()) AppInfo(name = appName, version = appVersion ?: "") else null
    // Passing clientInfo makes the SDK ignore the standalone appInfo param, so nest it.
    val clientInfo = ClientInfo(
      sdk = call.argument<String>("sdkName")!!,
      sdkVersion = call.argument<String>("sdkVersion")!!,
      lang = "flutter", langVersion = "disabled", appInfo = appInfo)
    Log.d("suprsend", "bridge-configure() called")
    Log.d("suprsend", "bridge-publicKey=$publicKey")
    Log.d("suprsend", "bridge-host=$host")
    Log.d("suprsend", "bridge-appName=$appName")
    Log.d("suprsend", "bridge-appVersion=$appVersion")
    Log.d("suprsend", "bridge-appInfo=$appInfo")
    Log.d("suprsend", "bridge-clientInfo=$clientInfo")
    SuprSend.initialize(context = context, publicApiKey = publicKey, clientInfo = clientInfo, host = host)
    result.success(null)
  }

  private fun enableLogging(result: Result) {
    runCatching { SuprSend.getInstance().setLogLevel(LogLevel.VERBOSE) }
    result.success(null)
  }

  private fun isIdentified(call: MethodCall, result: Result) {
    val checkUserToken = call.argument<Boolean>("checkUserToken") ?: false
    val identified = runCatching { SuprSend.getInstance().isIdentified(checkUserToken) }
      .getOrDefault(false)
    result.success(identified)
  }

  private fun getDistinctId(result: Result) {
    val distinctId = runCatching { SuprSend.getInstance().getDistinctId() }.getOrNull()
    result.success(distinctId)
  }

  private fun runAsync(call: MethodCall, result: Result) {
    executor.execute {
      val response: ApiResponse? = try {
        dispatch(call)
      } catch (e: Exception) {
        ApiResponse(status = ResponseStatus.ERROR, message = e.message, exception = e)
      }
      mainHandler.post { result.success(response?.let { toMap(it) } ?: successMap()) }
    }
  }

  private fun dispatch(call: MethodCall): ApiResponse? {
    val ss = SuprSend.getInstance()
    val user = ss.user
    return when (call.method) {
      "identify" -> {
        val userToken = call.argument<String>("userToken")
        Log.i("suprsend", "bridge-identify is commented:$userToken")
        currentUserToken = userToken
        val refreshCallback =
          if (call.argument<Boolean>("hasRefreshUserToken") == true) refreshTokenCallback() else null
        ss.identify(
          distinctId = call.argument<String>("distinctId") ?: "",
          userToken = userToken,
          refreshUserToken = refreshCallback,
        )
      }
      "reset" -> {
        ss.reset(call.argument<Boolean>("unsubscribePush") ?: true)
        null
      }
      "track" -> {
        Log.i("suprsend", "bridge-track HIT — trackEvent is commented")
        val event = call.argument<String>("event") ?: ""
        val properties = jsonOf(call.argument("properties"))
        if (properties != null) ss.track(event, properties) else ss.track(event)
      }
      "set" -> user.set(requireJson(call, "properties"))
      "setOnce" -> user.setOnce(requireJson(call, "properties"))
      "increment" -> user.increment(numberMap(call.argument("properties")))
      "append" -> user.append(requireJson(call, "properties"))
      "remove" -> user.remove(requireJson(call, "properties"))
      "unset" -> user.unset(call.argument<List<String>>("keys") ?: emptyList())
      "addEmail" -> user.addEmail(call.argument<String>("value") ?: "")
      "removeEmail" -> user.removeEmail(call.argument<String>("value") ?: "")
      "addSms" -> user.addSms(call.argument<String>("value") ?: "")
      "removeSms" -> user.removeSms(call.argument<String>("value") ?: "")
      "addWhatsapp" -> user.addWhatsapp(call.argument<String>("value") ?: "")
      "removeWhatsapp" -> user.removeWhatsapp(call.argument<String>("value") ?: "")
      "setPreferredLanguage" -> user.setPreferredLanguage(call.argument<String>("value") ?: "")
      "setTimezone" -> user.setTimezone(call.argument<String>("value") ?: "")
      "setAndroidFcmPush" -> user.addFcmPush(call.argument<String>("token") ?: "")
      else -> null
    }
  }

  /**
   * Builds a native [RefreshTokenCallback] that bridges to the Dart
   * `refreshUserToken` callback. The native SDK invokes [getToken] synchronously
   * on a worker thread; we hop to the main thread to invoke the Flutter channel
   * and block the worker thread until Dart returns the new token. This never
   * runs on the platform main thread, so blocking here is safe.
   */
  private fun refreshTokenCallback() = object : RefreshUserTokenCallback {
    override fun getToken(distinctId: String): String {
      val latch = CountDownLatch(1)
      val holder = arrayOfNulls<String>(1)
      mainHandler.post {
        channel.invokeMethod(
          "refreshUserToken",
          mapOf("distinctId" to distinctId, "oldUserToken" to currentUserToken),
          object : Result {
            override fun success(result: Any?) {
              holder[0] = result as? String
              latch.countDown()
            }

            override fun error(code: String, message: String?, details: Any?) {
              latch.countDown()
            }

            override fun notImplemented() {
              latch.countDown()
            }
          },
        )
      }
      latch.await(REFRESH_TOKEN_TIMEOUT_SECONDS, TimeUnit.SECONDS)
      val newToken = holder[0]
      if (!newToken.isNullOrBlank()) currentUserToken = newToken
      return newToken ?: ""
    }
  }

  private fun requireJson(call: MethodCall, key: String): JSONObject =
    jsonOf(call.argument(key)) ?: JSONObject()

  private fun jsonOf(value: Map<String, Any?>?): JSONObject? =
    if (value == null) null else JSONObject(value)

  private fun numberMap(value: Map<String, Any?>?): Map<String, Number> {
    val out = HashMap<String, Number>()
    value?.forEach { (k, v) -> if (v is Number) out[k] = v }
    return out
  }

  private fun toMap(response: ApiResponse): Map<String, Any?> = mapOf(
    "status" to if (response.isSuccess()) "success" else "error",
    "statusCode" to response.statusCode,
    "errorType" to response.errorType?.name,
    "errorMessage" to (response.message ?: response.exception?.message),
  )

  private fun successMap(): Map<String, Any?> = mapOf("status" to "success")
}
