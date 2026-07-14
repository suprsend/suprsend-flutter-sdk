package com.suprsend.flutterexample

import android.util.Log
import app.suprsend.SuprSend
import app.suprsend.notification.SSNotificationHelper
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * A custom FCM service that replaces SuprSend's bundled
 * `app.suprsend.fcm.SSFirebaseMessagingService`. It forwards the FCM token and
 * incoming messages to SuprSend, and is the place to add app-specific handling.
 *
 * Registered in AndroidManifest.xml, where the bundled service is opted out via
 * `tools:node="remove"`.
 */
class SuprSendMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        Log.d("SuprSendPush", "onNewToken: $token")
        // Forward the FCM token to SuprSend so it can deliver push.
        SuprSend.getInstance().user.setAndroidFcmPush(token)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        // --- customization hook: inspect message.data, route, or render your
        //     own notification here before/instead of the line below ---
        SSNotificationHelper.showFCMNotification(applicationContext, message)
    }
}
