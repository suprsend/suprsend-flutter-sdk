package com.suprsend.suprsend_flutter_sdk_example

import android.app.Application
import app.suprsend.SSApi
import com.suprsend.suprsend_flutter_sdk_example.BuildConfig.*

class SuprsendFlutterPluginTestApplication: Application() {

  companion object {
    const val TAG = "ClientSuprsend$VERSION_NAME"
    lateinit var app: SuprsendFlutterPluginTestApplication
  }

  override fun onCreate() {
    app = this
    SSApi.init(this, SS_API_KEY, SS_API_SECRET, SS_API_BASE_URL)
    SSApi.initXiaomi(this, XIAOMI_APP_ID, XIAOMI_API_KEY)
    super.onCreate()
  }
  
}
