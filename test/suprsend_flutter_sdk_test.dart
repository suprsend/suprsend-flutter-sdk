import 'dart:collection';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suprsend_flutter_sdk/suprsend.dart';
import 'package:suprsend_flutter_sdk/log_levels.dart';

void main() {
  const MethodChannel channel = MethodChannel('suprsend_flutter_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  test('getPlatformVersion', () async {
    var platformVersion = suprsend.platformVersion;
    log("PlatformVersion: $platformVersion");
    expect(await platformVersion, '42');
  });

  test('setLogLevel', () {
    suprsend.setLogLevel(LogLevels.VERBOSE);
  });

  test('set', () {
    Map<String, Object> map = HashMap();
    map["test_key"] = "test_value_${DateTime.now().millisecondsSinceEpoch}";
    suprsend.user.set(map);
  });

  test('unSet', () {
    List<String> list = ["test_key"];
    suprsend.user.unSet(list);
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
