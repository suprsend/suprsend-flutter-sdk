import UIKit
import Flutter
import SuprSendSdk

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        let suprSendConfiguration = SuprSendSDKConfiguration(withKey: "kfWdrPL1nFqs7OUihiBn", secret:"From1HA1ZiSXs3ofBHXh", baseUrl: "https://collector-staging.suprsend.workers.dev")
        SuprSend.shared.configureWith(configuration: suprSendConfiguration  , launchOptions: launchOptions)
        SuprSend.shared.enableLogging()
        SuprSend.shared.registerForPushNotifications()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let  token = tokenParts.joined()
        SuprSend.shared.setPushNotificationToken(token: token)  // Send APNS Token to SuprSend
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.isSuprSendNotification() {
            SuprSend.shared.userNotificationCenter(center, didReceive: response)
        }
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        
        if notification.isSuperSendNotification() {
            SuprSend.shared.userNotificationCenter(center, willPresent: notification)
        }
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            // Fallback on earlier versions
            completionHandler([.alert, .badge, .sound])
        }
    }
}
