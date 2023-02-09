package com.suprsend.suprsend_flutter_sdk

import android.content.Context
import android.os.Build
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import app.suprsend.SSApi
import app.suprsend.base.LogLevel
import app.suprsend.notification.SSNotificationHelper
import com.suprsend.suprsend_flutter_sdk.MethodConstants.getPlatformVersion
import com.suprsend.suprsend_flutter_sdk.MethodConstants.init
import com.suprsend.suprsend_flutter_sdk.MethodConstants.initXiaomi
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setLogLevel
import com.suprsend.suprsend_flutter_sdk.MethodConstants.identify
import com.suprsend.suprsend_flutter_sdk.MethodConstants.set
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setOnce
import com.suprsend.suprsend_flutter_sdk.MethodConstants.increment
import com.suprsend.suprsend_flutter_sdk.MethodConstants.append
import com.suprsend.suprsend_flutter_sdk.MethodConstants.remove
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSet
import com.suprsend.suprsend_flutter_sdk.MethodConstants.track
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setEmail
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSetEmail
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setSms
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSetSms
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setWhatsApp
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSetWhatsApp
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setAndroidFcmPush
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSetAndroidFcmPush
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setAndroidXiaomiPush
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSetAndroidXiaomiPush
import com.suprsend.suprsend_flutter_sdk.MethodConstants.setSuperProperties
import com.suprsend.suprsend_flutter_sdk.MethodConstants.unSetSuperProperty
import com.suprsend.suprsend_flutter_sdk.MethodConstants.purchaseMade
import com.suprsend.suprsend_flutter_sdk.MethodConstants.showNotification
import com.suprsend.suprsend_flutter_sdk.MethodConstants.flush
import com.suprsend.suprsend_flutter_sdk.MethodConstants.reset
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import org.json.JSONObject

/** SuprsendFlutterSdkPlugin */
class SuprsendFlutterSdkPlugin : FlutterPlugin, MethodCallHandler {

  companion object {
    const val NAME = "SuprsendFlutterSdk"
    val TAG by lazy { "SUPRSEND_FLUTTER_v${BuildConfig.SS_SDK_VERSION_NAME}" }

    private var loggedIn: Boolean = false
    fun isLoggedIn() = loggedIn
  }

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel: MethodChannel

  private lateinit var context: Context
  private lateinit var suprsendInstance: SSApi

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext

    suprsendInstance = SSApi.getInstance()
    suprsendInstance.setLogLevel(LogLevel.VERBOSE)
    val properties = JSONObject()
    properties.apply {
      put("flutter_sdk_version_code", "${BuildConfig.SS_SDK_VERSION_CODE}")
      put("flutter_sdk_version_name", BuildConfig.SS_SDK_VERSION_NAME)
      put("sdk_type", "Flutter SDK")
      put("os_version", "Android ${Build.VERSION.RELEASE}")
    }
    suprsendInstance.setSuperProperties(properties)

    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "suprsend_flutter_sdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    ensureInstance()
    when (call.method) {
      getPlatformVersion     -> getPlatformVersion(result)
      init                   -> init(call)
      initXiaomi             -> initXiaomi(call)
      setLogLevel            -> setLogLevel(call)
      identify               -> identify(call)
      set                    -> set(call.arguments())
      setOnce                -> setOnce(call.arguments())
      increment              -> increment(call.arguments())
      append                 -> append(call.arguments())
      remove                 -> remove(call.arguments())
      unSet                  -> unSet(call)
      track                  -> track(call.arguments())
      setEmail               -> setEmail(call)
      unSetEmail             -> unSetEmail(call)
      setSms                 -> setSms(call)
      unSetSms               -> unSetSms(call)
      setWhatsApp            -> setWhatsApp(call)
      unSetWhatsApp          -> unSetWhatsApp(call)
      setAndroidFcmPush      -> setAndroidFcmPush(call)
      unSetAndroidFcmPush    -> unSetAndroidFcmPush(call)
      setAndroidXiaomiPush   -> setAndroidXiaomiPush(call)
      unSetAndroidXiaomiPush -> unSetAndroidXiaomiPush(call)
      setSuperProperties     -> setSuperProperties(call.arguments())
      unSetSuperProperty     -> unSetSuperProperty(call)
      purchaseMade           -> purchaseMade(call.arguments())
      showNotification       -> showNotification(call)
      flush                  -> flush()
      reset                  -> reset(call)
      else                   -> result.notImplemented()
    }
  }

  private fun getPlatformVersion(result: MethodChannel.Result) {
    result.success("Android ${Build.VERSION.RELEASE}")
  }

  private fun init(call: MethodCall) {
    val apiKey = call.argument<String>("apiKey") ?: ""
    if (apiKey.isBlank()) {
      Log.e(TAG, "$init: Property `apiKey` cannot be blank")
      return
    }
    val apiSecret = call.argument<String>("apiSecret") ?: ""
    if (apiSecret.isBlank()) {
      Log.e(TAG, "$init: Property `apiSecret` cannot be blank")
      return
    }
    if (call.hasArgument("apiBaseUrl")) {
      val apiBaseUrl = call.argument<String>("apiBaseUrl") ?: ""
      if (apiBaseUrl.isBlank()) {
        Log.e(TAG, "$init: Property `apiBaseUrl` if used, cannot be blank")
        return
      }
      SSApi.init(context, apiKey, apiSecret, apiBaseUrl)
    } else {
      SSApi.init(context, apiKey, apiSecret)
    }
    if (BuildConfig.DEBUG) {
      toast("[DEBUG] Called init for Suprsend SDK")
    }
  }

  private fun initXiaomi(call: MethodCall) {
    val appId = call.argument<String>("appId") ?: ""
    if (appId.isBlank()) {
      Log.e(TAG, "$initXiaomi: Property `appId` cannot be blank")
      return
    }
    val apiKey = call.argument<String>("apiKey") ?: ""
    if (apiKey.isBlank()) {
      Log.e(TAG, "$initXiaomi: Property `apiKey` cannot be blank")
      return
    }
    SSApi.initXiaomi(context, appId, apiKey)
  }

  private fun setLogLevel(call: MethodCall) {
    val logLevelInt = call.argument<Int>("logLevel") ?: Int.MAX_VALUE
    val logLevel = when (logLevelInt) {
      101  -> LogLevel.VERBOSE
      102  -> LogLevel.DEBUG
      103  -> LogLevel.INFO
      104  -> LogLevel.ERROR
      else -> if (BuildConfig.DEBUG) LogLevel.DEBUG else LogLevel.OFF
    }
    suprsendInstance.setLogLevel(logLevel)
  }

  private fun identify(call: MethodCall) {
    val uniqueId = call.argument<String>("uniqueId") ?: ""
    if (uniqueId.isBlank()) {
      Log.e(TAG, "Unique ID cannot be blank")
      return
    }
    if (BuildConfig.DEBUG) {
      toast("[DEBUG] Called identify with ID: $uniqueId")
    }
    suprsendInstance.identify(uniqueId)
    loggedIn = true
  }

  private fun set(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$set: Property parameters are empty or null, ignoring")
      return
    }
    val jsonData = JSONObject(properties.filter { it.key.isNotBlank() })
    suprsendInstance.getUser().set(jsonData)
  }

  private fun setOnce(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$setOnce: Property parameters are empty or null, ignoring")
      return
    }
    val jsonData = JSONObject(properties.filter { it.key.isNotBlank() })
    suprsendInstance.getUser().setOnce(jsonData)
  }

  private fun increment(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$increment: Property parameters are empty or null, ignoring")
      return
    }
    val formatterProperties = hashMapOf<String, Number>()
    properties
      .filter { it.key.isNotBlank() && it.value is Number }
      .entries.forEach {
        formatterProperties[it.key] = it.value as Number
      }
    suprsendInstance.getUser().increment(formatterProperties)
  }

  private fun append(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$append: Property parameters are empty or null, ignoring")
      return
    }
    val jsonData = JSONObject(properties.filter { it.key.isNotBlank() })
    suprsendInstance.getUser().append(jsonData)
  }

  private fun remove(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$remove: Property parameters are empty or null, ignoring")
      return
    }
    val jsonData = JSONObject(properties.filter { it.key.isNotBlank() })
    suprsendInstance.getUser().remove(jsonData)
  }

  private fun unSet(call: MethodCall) {
    val keys = call.argument<List<String?>>("keys") ?: arrayListOf()
    if (keys.isNullOrEmpty()) {
      Log.w(TAG, "$unSet: Property parameters are empty or null, ignoring")
      return
    }
    val filteredKeys = ArrayList<String>()
    keys.forEach {
      if (it != null && it.isNotBlank()) {
        filteredKeys.add(it)
      }
    }
    suprsendInstance.getUser().unSet(filteredKeys)
  }

  private fun track(params: Map<String, Any?>?) {
    if (params.isNullOrEmpty()) {
      Log.w(TAG, "$track: Property parameters are empty or null, ignoring")
      return
    }
    val eventName = params["eventName"] as String
    val properties = params["properties"] as Map<String, Any?>?
    val jsonData = if (properties != null) {
      JSONObject(properties.filter { it.key.isNotBlank() })
    } else {
      null
    }
    if(jsonData!=null){
      suprsendInstance.track(eventName, jsonData)
    }
  }

  private fun setEmail(call: MethodCall) {
    val email = call.argument<String>("email") ?: ""
    if (email.isBlank()) {
      Log.e(TAG, "$setEmail: Property `email` cannot be blank")
      return
    }
    suprsendInstance.getUser().setEmail(email)
  }

  private fun unSetEmail(call: MethodCall) {
    val email = call.argument<String>("email") ?: ""
    if (email.isBlank()) {
      Log.e(TAG, "$unSetEmail: Property `email` cannot be blank")
      return
    }
    suprsendInstance.getUser().unSetEmail(email)
  }

  private fun setSms(call: MethodCall) {
    val mobile = call.argument<String>("mobile") ?: ""
    if (mobile.isBlank()) {
      Log.e(TAG, "$setSms: Property `mobile` cannot be blank")
      return
    }
    suprsendInstance.getUser().setSms(mobile)
  }

  private fun unSetSms(call: MethodCall) {
    val mobile = call.argument<String>("mobile") ?: ""
    if (mobile.isBlank()) {
      Log.e(TAG, "$unSetSms: Property `mobile` cannot be blank")
      return
    }
    suprsendInstance.getUser().unSetSms(mobile)
  }

  private fun setWhatsApp(call: MethodCall) {
    val mobile = call.argument<String>("mobile") ?: ""
    if (mobile.isBlank()) {
      Log.e(TAG, "$setWhatsApp: Property `mobile` cannot be blank")
      return
    }
    suprsendInstance.getUser().setWhatsApp(mobile)
  }

  private fun unSetWhatsApp(call: MethodCall) {
    val mobile = call.argument<String>("mobile") ?: ""
    if (mobile.isBlank()) {
      Log.e(TAG, "$unSetWhatsApp: Property `mobile` cannot be blank")
      return
    }
    suprsendInstance.getUser().unSetWhatsApp(mobile)
  }

  private fun setAndroidFcmPush(call: MethodCall) {
    val token = call.argument<String>("token") ?: ""
    if (token.isBlank()) {
      Log.e(TAG, "$setAndroidFcmPush: Property `token` cannot be blank")
      return
    }
    suprsendInstance.getUser().setAndroidFcmPush(token)
  }

  private fun unSetAndroidFcmPush(call: MethodCall) {
    val token = call.argument<String>("token") ?: ""
    if (token.isBlank()) {
      Log.e(TAG, "$unSetAndroidFcmPush: Property `token` cannot be blank")
      return
    }
    suprsendInstance.getUser().unSetAndroidFcmPush(token)
  }

  private fun setAndroidXiaomiPush(call: MethodCall) {
    val token = call.argument<String>("token") ?: ""
    if (token.isBlank()) {
      Log.e(TAG, "$setAndroidXiaomiPush: Property `token` cannot be blank")
      return
    }
    suprsendInstance.getUser().setAndroidXiaomiPush(token)
  }

  private fun unSetAndroidXiaomiPush(call: MethodCall) {
    val token = call.argument<String>("token") ?: ""
    if (token.isBlank()) {
      Log.e(TAG, "$unSetAndroidXiaomiPush: Property `token` cannot be blank")
      return
    }
    suprsendInstance.getUser().unSetAndroidXiaomiPush(token)
  }

  private fun setSuperProperties(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$setSuperProperties: Property parameters are empty or null, ignoring")
      return
    }
    val jsonData = JSONObject(properties.filter { it.key.isNotBlank() })
    suprsendInstance.setSuperProperties(jsonData)
  }

  private fun unSetSuperProperty(call: MethodCall) {
    val key = call.argument<String>("key") ?: ""
    if (key.isBlank()) {
      Log.e(TAG, "$unSetSuperProperty: Property `key` cannot be blank")
      return
    }
    suprsendInstance.unSetSuperProperty(key)
  }

  private fun purchaseMade(properties: Map<String, Any?>?) {
    if (properties.isNullOrEmpty()) {
      Log.w(TAG, "$purchaseMade: Property parameters are empty or null, ignoring")
      return
    }
    val jsonData = JSONObject(properties.filter { it.key.isNotBlank() })
    suprsendInstance.purchaseMade(jsonData)
  }

  private fun showNotification(call: MethodCall) {
    val notificationPayloadJson = call.argument<String>("notificationPayloadJson") ?: ""
    if (notificationPayloadJson.isBlank()) {
      Log.e(TAG, "$showNotification: Property `notificationPayloadJson` cannot be blank")
      return
    }
    SSNotificationHelper.showSSNotification(context, notificationPayloadJson)
  }

  private fun flush() {
    suprsendInstance.flush()
  }

  private fun reset(call: MethodCall) {
    val unSubscribeNotification = call.argument<Boolean>("unsubscribeNotification") ?: true
    suprsendInstance.reset(unSubscribeNotification)
    loggedIn = false
  }

  /**
   * Helper functions
   * */

  private fun ensureInstance() {
    if (::suprsendInstance.isInitialized.not()) {
      suprsendInstance = SSApi.Companion.getInstance();
    }
  }

  private fun toast(message: String, duration: Int = Toast.LENGTH_LONG) {
    Toast.makeText(context, message, duration).show()
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
