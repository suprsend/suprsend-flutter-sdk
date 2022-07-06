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
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
