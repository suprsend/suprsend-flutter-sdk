import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'suprsend_flutter_sdk_platform_interface.dart';

/// An implementation of [SuprsendFlutterSdkPlatform] that uses method channels.
class MethodChannelSuprsendFlutterSdk extends SuprsendFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('suprsend_flutter_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
