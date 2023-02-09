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
    case "set":
        handleSet(call, result: result)
        break
    case "setOnce":
        handleSetOnce(call, result: result)
        break
    case "increment":
        handleIncrement(call, result: result)
        break
    case "append":
        handleAppend(call, result: result)
        break
    case "remove":
        handleRemove(call, result: result)
        break
    case "unSet":
        handleUnSet(call, result: result)
        break
    case "setEmail":
        handleSetEmail(call, result: result)
        break
    case "unSetEmail":
        handleUnSetEmail(call, result: result)
        break
    case "setSms":
        handleSetSms(call, result: result)
        break
    case "unSetSms":
        handleUnSetSms(call, result: result)
        break
    case "setWhatsApp":
        handleSetWhatsApp(call, result: result)
        break
    case "unSetWhatsApp":
        handleUnSetWhatsApp(call, result: result)
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
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let unsubscribeNotification = arguments["unsubscribeNotification"] as! Bool
    SuprSend.shared.reset(unsubscribeNotification: unsubscribeNotification)
}

private func handleTrack(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let eventName = arguments["eventName"] as! String
    let properties = arguments["properties"] as? [String: Any] ?? [String: Any]()
    SuprSend.shared.track(eventName: eventName, properties: properties)
}

private func handleSetSuperProperties(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    SuprSend.shared.setSuperProperties(properties: arguments);
}

private func handleUnSetSuperProperty(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let key = arguments["key"] as! String
    SuprSend.shared.unSetSuperProperty(key: key);
}

public func handlePurchaseMade(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    SuprSend.shared.purchaseMade(properties: arguments);
}

public func handleFlush(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    SuprSend.shared.flush()
}

public func handleSetLogLevel(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    SuprSend.shared.enableLogging();
}

public func handleSet(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    SuprSend.shared.set(properties: arguments);
}

public func handleSetOnce(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    SuprSend.shared.setOnce(properties: arguments);
}

public func handleIncrement(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Float] ?? [String: Float]()
    SuprSend.shared.increment(properties: arguments);
}

public func handleAppend(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    SuprSend.shared.append(properties: arguments);
}

public func handleRemove(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    SuprSend.shared.remove(properties: arguments);
}

public func handleUnSet(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let keys = arguments["keys"] as! [String]
    SuprSend.shared.unSet(keys: keys);
}

public func handleSetEmail(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let email = arguments["email"] as! String
    SuprSend.shared.setEmail(emailId: email);
}

public func handleUnSetEmail(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let email = arguments["email"] as! String
    SuprSend.shared.unSetEmail(emailId: email);
}

public func handleSetSms(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let mobile = arguments["mobile"] as! String
    SuprSend.shared.setSms(mobileNumber: mobile);
}

public func handleUnSetSms(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let mobile = arguments["mobile"] as! String
    SuprSend.shared.unSetSms(mobileNumber: mobile);
}

public func handleSetWhatsApp(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let mobile = arguments["mobile"] as! String
    SuprSend.shared.setWhatsApp(mobileNumber: mobile);
}

public func handleUnSetWhatsApp(_ call: FlutterMethodCall, result: @escaping FlutterResult){
    let arguments = call.arguments as? [String: Any] ?? [String: Any]()
    let mobile = arguments["mobile"] as! String
    SuprSend.shared.unSetWhatsApp(mobileNumber: mobile);
}
