import Flutter
import UIKit
import SuprSendSdk

public class SwiftSuprsendFlutterSdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "suprsend_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSuprsendFlutterSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "identify":
        handleIdentify(call, result: result)
        break
    case "reset":
        handleReset(call, result: result)
        break
    case "track":
        handleTrack(call, result: result)
        break
    default:
        result(FlutterMethodNotImplemented)
    }
    return
  }
}

private func handleIdentify(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let distinctId = arguments["uniqueId"] as! String
    SuprSend.shared.identify(identity: distinctId);
}

private func handleReset(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    SuprSend.shared.reset()
}

private func handleTrack(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let eventName = arguments["eventName"] as! String
    let properties = arguments["properties"] as? [String: Any]
    SuprSend.shared.track(eventName: eventName, properties: properties!)
}
