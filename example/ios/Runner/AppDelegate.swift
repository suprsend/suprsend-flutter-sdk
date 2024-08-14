import UIKit
import Flutter
import SuprSendSdk // Add this

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        //  suprsend initialization code
        let suprSendConfiguration = SuprSendSDKConfiguration(withKey: "<your workspace_key>", secret:"your workspace_secret")
        SuprSend.shared.configureWith(configuration: suprSendConfiguration  , launchOptions: launchOptions)
        SuprSend.shared.enableLogging()
        var options: UNAuthorizationOptions = [.badge, .alert, .sound]
        SuprSend.shared.registerForPushNotifications(options: options)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    //    suprsend code block from below for iOS push related events
    
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
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]){
        SuprSend.shared.application(application, didReceiveRemoteNotification: userInfo)
    }
    
    @available(iOS 10.0, *)
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .badge, .sound])
        } else {
            completionHandler([.alert, .badge, .sound])
        }
    }
}
