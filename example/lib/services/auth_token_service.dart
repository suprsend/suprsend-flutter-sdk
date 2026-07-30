import 'dart:convert';

import 'package:http/http.dart' as http;

// Fetches a SuprSend user token (JWT) from your backend (demo endpoint; authenticate this in a real app).
class AuthTokenService {
  const AuthTokenService(this.baseUrl);

  // Base URL of your token endpoint, configured via SUPRSEND_AUTH_TOKEN_URL in .env.
  final String baseUrl;

  bool get isConfigured => baseUrl.isNotEmpty;

  // Returns the user token for distinctId, or null if it can't be fetched.
  // When tenantId is set it's forwarded to the backend as a query param.
  Future<String?> fetchUserToken(String distinctId, {String? tenantId}) async {
    if (!isConfigured) return null;
    var uri = Uri.parse(
      '$baseUrl/authentication-token/${Uri.encodeComponent(distinctId)}',
    );
    if (tenantId != null && tenantId.isNotEmpty) {
      uri = uri.replace(queryParameters: {
        ...uri.queryParameters,
        'tenant_id': tenantId,
      });
    }
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final body = json.decode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final token = body['token'];
      return (token is String && token.isNotEmpty) ? token : null;
    } catch (_) {
      // Network / parse errors: caller decides how to proceed.
      return null;
    }
  }
}
