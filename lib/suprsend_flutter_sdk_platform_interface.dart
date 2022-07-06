import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'suprsend_flutter_sdk_method_channel.dart';

abstract class SuprsendFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a SuprsendFlutterSdkPlatform.
  SuprsendFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static SuprsendFlutterSdkPlatform _instance = MethodChannelSuprsendFlutterSdk();

  /// The default instance of [SuprsendFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelSuprsendFlutterSdk].
  static SuprsendFlutterSdkPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SuprsendFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(SuprsendFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
