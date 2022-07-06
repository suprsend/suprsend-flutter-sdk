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
    case "setSuperProperties":
        handleSetSuperProperties(call, result: result)
        break
    case "unSetSuperProperty":
        handleUnSetSuperProperty(call, result: result)
        break
    case "purchaseMade":
        handlePurchaseMade(call, result: result)
        break
    case "flush":
        handleFlush(call, result: result)
        break
    case "setLogLevel":
        handleSetLogLevel(call, result: result)
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

private func handleSetSuperProperties(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let properties = arguments["properties"] as! [String: Any]
    SuprSend.shared.setSuperProperties(properties: properties);
}

private func handleUnSetSuperProperty(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let key = arguments["propertyName"] as! String
    SuprSend.shared.unSetSuperProperty(key: key);
}

public func handlePurchaseMade(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let properties = arguments["properties"] as! [String: Any]
    SuprSend.shared.purchaseMade(properties: properties);
}

public func handleFlush(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    SuprSend.shared.flush()
}

public func handleSetLogLevel(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    SuprSend.shared.enableLogging();
}

