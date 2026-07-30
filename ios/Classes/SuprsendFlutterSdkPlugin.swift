import Flutter
import UIKit
import SuprSendSwift

public class SuprsendFlutterSdkPlugin: NSObject, FlutterPlugin {
  // Kept so the native SDK can call back into Dart (e.g. refreshUserToken).
  private var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "suprsend_flutter_sdk", binaryMessenger: registrar.messenger())
    let instance = SuprsendFlutterSdkPlugin()
    instance.channel = channel
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    let client = SuprSendClient.shared
    let user = client.user

    switch call.method {

    case "configure":
      let publicKey = args["publicKey"] as? String ?? ""
      let host = args["host"] as? String
      let appName = args["appName"] as? String
      let appVersion = args["appVersion"] as? String
      let appInfo = (appName != nil || appVersion != nil)
        ? AppInfo(name: appName, version: appVersion) : nil
      // Report this as the Flutter SDK (not the native Swift SDK) in the user-agent.
      let clientUserAgent = ClientUserAgentConfig(
        sdk: args["sdkName"] as? String,
        sdkVersion: args["sdkVersion"] as? String,
        lang: "flutter",
        langVersion: "disabled")
      let options = Options(
        host: host, appInfo: appInfo, clientUserAgent: clientUserAgent)
      client.configure(publicKey: publicKey, options: options)
      result(nil)

    case "identify":
      let distinctID = args["distinctId"] as? String ?? ""
      let userToken = args["userToken"] as? String
      let tenantId = args["tenantId"] as? String
      let hasRefresh = args["hasRefreshUserToken"] as? Bool ?? false
      let options: AuthenticateOptions? = hasRefresh
        ? AuthenticateOptions(refreshUserToken: { [weak self] oldUserToken, _ in
            await self?.requestRefreshedToken(oldUserToken)
          })
        : nil
      Task {
        let r = await client.identify(distinctID: distinctID, userToken: userToken, tenantId: tenantId, options: options)
        self.reply(result, r)
      }

    case "changeTenant":
      let tenantId = args["tenantId"] as? String ?? ""
      client.changeTenant(tenantId: tenantId)
      result(nil)

    case "isIdentified":
      let check = args["checkUserToken"] as? Bool ?? false
      result(client.isIdentified(checkUserToken: check))

    case "getDistinctId":
      result(client.distinctID)

    case "reset":
      let unsubscribePush = args["unsubscribePush"] as? Bool ?? true
      Task {
        let r = await client.reset(options: ResetOption(unsubscribePush: unsubscribePush))
        self.reply(result, r)
      }

    case "track":
      let event = args["event"] as? String ?? ""
      let properties = self.eventProperty(args["properties"] as? [String: Any])
      Task {
        let r = await client.track(event: event, properties: properties)
        self.reply(result, r)
      }

    case "enableLogging":
      client.enableLogging()
      result(nil)

    case "set":
      Task { self.reply(result, await user.set(properties: self.requireProps(args))) }
    case "setOnce":
      Task { self.reply(result, await user.setOnce(properties: self.requireProps(args))) }
    case "increment":
      Task { self.reply(result, await user.increment(properties: self.floatProps(args))) }
    case "append":
      Task { self.reply(result, await user.append(properties: self.requireProps(args))) }
    case "remove":
      Task { self.reply(result, await user.remove(properties: self.requireProps(args))) }
    case "unset":
      let keys = args["keys"] as? [String] ?? []
      Task { self.reply(result, await user.unset(keys: keys)) }

    case "addEmail":
      Task { self.reply(result, await user.addEmail(self.value(args))) }
    case "removeEmail":
      Task { self.reply(result, await user.removeEmail(self.value(args))) }
    case "addSms":
      Task { self.reply(result, await user.addSMS(self.value(args))) }
    case "removeSms":
      Task { self.reply(result, await user.removeSMS(self.value(args))) }
    case "addWhatsapp":
      Task { self.reply(result, await user.addWhatsapp(self.value(args))) }
    case "removeWhatsapp":
      Task { self.reply(result, await user.removeWhatsapp(self.value(args))) }
    case "setPreferredLanguage":
      Task { self.reply(result, await user.setPreferredLanguage(self.value(args))) }
    case "setTimezone":
      Task { self.reply(result, await user.setTimezone(self.value(args))) }

    // Android-only: no-op on iOS.
    case "setAndroidFcmPush":
      self.replySuccess(result)

    case "addiOSPush":
      let token = args["token"] as? String ?? ""
      Task { self.reply(result, await user.addiOSPush(token)) }
    case "removeiOSPush":
      let token = args["token"] as? String ?? ""
      Task { self.reply(result, await user.removeiOSPush(token)) }

    case "registerForPush":
      Task {
        do {
          let r = try await client.push.registerPush()
          self.reply(result, r)
        } catch {
          self.replyError(result, error)
        }
      }
    case "updatePushSubscription":
      Task {
        await client.push.updatePushSubscription()
        self.replySuccess(result)
      }
    case "removePushSubscription":
      Task {
        await client.push.removePushSubscription()
        self.replySuccess(result)
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // Bridges the native refreshUserToken callback to Dart; lets Dart derive the JWT payload so both platforms match.
  private func requestRefreshedToken(_ oldUserToken: String) async -> String? {
    await withCheckedContinuation { continuation in
      DispatchQueue.main.async {
        guard let channel = self.channel else {
          continuation.resume(returning: nil)
          return
        }
        channel.invokeMethod(
          "refreshUserToken",
          arguments: ["oldUserToken": oldUserToken]
        ) { result in
          continuation.resume(returning: result as? String)
        }
      }
    }
  }

  private func value(_ args: [String: Any]) -> String {
    return args["value"] as? String ?? ""
  }

  private func requireProps(_ args: [String: Any]) -> [String: Encodable] {
    return eventProperty(args["properties"] as? [String: Any]) ?? [:]
  }

  private func eventProperty(_ map: [String: Any]?) -> [String: Encodable]? {
    guard let map = map else { return nil }
    var out: [String: Encodable] = [:]
    for (key, val) in map { out[key] = AnyEncodableValue(val) }
    return out
  }

  private func floatProps(_ args: [String: Any]) -> [String: Float] {
    var out: [String: Float] = [:]
    if let map = args["properties"] as? [String: Any] {
      for (key, val) in map {
        if let number = val as? NSNumber { out[key] = number.floatValue }
      }
    }
    return out
  }

  private func reply(_ result: @escaping FlutterResult, _ response: APIResponse) {
    var dict: [String: Any] = ["status": response.status.rawValue]
    if let code = response.statusCode { dict["statusCode"] = code }
    if let type = response.error?.type?.rawValue { dict["errorType"] = type }
    if let message = response.error?.message { dict["errorMessage"] = message }
    DispatchQueue.main.async { result(dict) }
  }

  private func replySuccess(_ result: @escaping FlutterResult) {
    DispatchQueue.main.async { result(["status": "success"]) }
  }

  private func replyError(_ result: @escaping FlutterResult, _ error: Error) {
    DispatchQueue.main.async {
      result(["status": "error", "errorMessage": error.localizedDescription])
    }
  }
}

private struct AnyEncodableValue: Encodable {
  let value: Any
  init(_ value: Any) { self.value = value }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch value {
    case let bool as Bool where isBool(value):
      try container.encode(bool)
    case let int as Int:
      try container.encode(int)
    case let double as Double:
      try container.encode(double)
    case let number as NSNumber:
      try container.encode(number.doubleValue)
    case let string as String:
      try container.encode(string)
    case let array as [Any]:
      try container.encode(array.map { AnyEncodableValue($0) })
    case let dict as [String: Any]:
      try container.encode(dict.mapValues { AnyEncodableValue($0) })
    case is NSNull:
      try container.encodeNil()
    default:
      try container.encodeNil()
    }
  }

  private func isBool(_ value: Any) -> Bool {
    return (value as? NSNumber)?.objCType.pointee == 0x63 // 'c' == CFBoolean
  }
}
