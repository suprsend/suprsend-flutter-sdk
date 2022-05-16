package com.suprsend.suprsend_flutter_sdk_example

import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    checkAndShowDeeplinkUri(intent)
  }

  override fun onNewIntent(newIntent: Intent) {
    super.onNewIntent(newIntent)
    checkAndShowDeeplinkUri(newIntent)
  }

  private fun checkAndShowDeeplinkUri(intent: Intent) {
    val uri = intent.data
    if (BuildConfig.DEBUG && uri != null) {
      val message = when (uri.scheme ?: "unknown") {
        "https"   -> "Deeplink URI: \n$uri"
        "app"     -> "Applink URI: \n$uri"
        else      -> "Unsupported URI: \n$uri"
      }
      Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
    }
  }

}
