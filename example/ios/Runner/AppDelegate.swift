import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Push is fully headless: the `firebase_messaging` plugin owns APNs / FCM
    // registration (via method swizzling) and notification delivery. Nothing
    // push-related lives here anymore.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
