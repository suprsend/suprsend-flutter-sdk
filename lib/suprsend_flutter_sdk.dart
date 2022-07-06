
import 'suprsend_flutter_sdk_platform_interface.dart';

class SuprsendFlutterSdk {
  Future<String?> getPlatformVersion() {
    return SuprsendFlutterSdkPlatform.instance.getPlatformVersion();
  }
}
