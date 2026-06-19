import UserNotifications
import SuprSendSwift

final class NotificationService: SuprSendNotificationService {
  // Must match the public key passed to SuprSend(...) in lib/main.dart.
  override func publicKey() -> String {
    "YOUR_PUBLIC_KEY"
  }
}
