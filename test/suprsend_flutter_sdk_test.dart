import 'package:flutter_test/flutter_test.dart';
import 'package:suprsend_flutter_sdk/suprsend_flutter_sdk.dart';

void main() {
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
