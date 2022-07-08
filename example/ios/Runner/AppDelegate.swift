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
    
//    get token and sent to suprsend
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let  token = tokenParts.joined()
        SuprSend.shared.setPushNotificationToken(token: token)  // Send APNS Token to SuprSend
    }
    
//    for capturing click event
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
    
//    for capturing delivery event
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        SuprSend.shared.application(application, didReceiveRemoteNotification: userInfo)
        
        completionHandler(.newData)
    }
    
//    for informing apple how it should present notification
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}
