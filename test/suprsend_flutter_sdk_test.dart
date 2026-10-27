import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SuprSendUser property methods', () {
    const channel = MethodChannel('suprsend_flutter_sdk');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('single key/value is sent as a one-entry map', () async {
      await SuprSend.user.set('name', 'Jane');
      await SuprSend.user.setOnce('signup_date', '2026-10-27');
      await SuprSend.user.increment('login_count', 1);
      await SuprSend.user.append('tags', 'flutter');
      await SuprSend.user.remove('tags', 'flutter');
      await SuprSend.user.unset('plan');

      expect(calls.map((c) => [c.method, c.arguments]).toList(), [
        ['set', {'properties': {'name': 'Jane'}}],
        ['setOnce', {'properties': {'signup_date': '2026-10-27'}}],
        ['increment', {'properties': {'login_count': 1}}],
        ['append', {'properties': {'tags': 'flutter'}}],
        ['remove', {'properties': {'tags': 'flutter'}}],
        ['unset', {'keys': ['plan']}],
      ]);
    });

    test('map / list forms are sent unchanged', () async {
      await SuprSend.user.set({'name': 'Jane', 'age': 30});
      final Map<String, dynamic> counters = {'login_count': 1, 'credits': 2.5};
      await SuprSend.user.increment(counters);
      await SuprSend.user.unset(['plan', 'age']);

      expect(calls.map((c) => [c.method, c.arguments]).toList(), [
        ['set', {'properties': {'name': 'Jane', 'age': 30}}],
        ['increment', {'properties': {'login_count': 1, 'credits': 2.5}}],
        ['unset', {'keys': ['plan', 'age']}],
      ]);
    });

    test('invalid arguments throw without calling native', () {
      expect(() => SuprSend.user.set('name'), throwsArgumentError);
      expect(() => SuprSend.user.set({'a': 1}, 2), throwsArgumentError);
      expect(() => SuprSend.user.set(42), throwsArgumentError);
      expect(() => SuprSend.user.increment({'a': 'x'}), throwsArgumentError);
      expect(() => SuprSend.user.unset([1]), throwsArgumentError);
      expect(calls, isEmpty);
    });
  });

  group('SSResponse', () {
    test('null payload is treated as success', () {
      final res = SSResponse.fromMap(null);
      expect(res.isSuccess, isTrue);
      expect(res.status, 'success');
    });

    test('parses a success map', () {
      final res = SSResponse.fromMap({'status': 'success', 'statusCode': 202});
      expect(res.isSuccess, isTrue);
      expect(res.statusCode, 202);
      expect(res.errorMessage, isNull);
    });

    test('parses an error map', () {
      final res = SSResponse.fromMap({
        'status': 'error',
        'statusCode': 400,
        'errorType': 'VALIDATION_ERROR',
        'errorMessage': 'invalid email',
      });
      expect(res.isSuccess, isFalse);
      expect(res.errorType, 'VALIDATION_ERROR');
      expect(res.errorMessage, 'invalid email');
    });
  });
}
