import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches a SuprSend user token (JWT) from your backend endpoint.
class AuthTokenService {
  const AuthTokenService(this.baseUrl);

  /// Base URL of your token endpoint, from `SUPRSEND_AUTH_TOKEN_URL` in `.env`.
  final String baseUrl;

  bool get isConfigured => baseUrl.isNotEmpty;

  /// Returns the user token for [distinctId], or `null` if it can't be fetched.
  Future<String?> fetchUserToken(String distinctId) async {
    if (!isConfigured) return null;
    final uri = Uri.parse(
      '$baseUrl/authentication-token/${Uri.encodeComponent(distinctId)}',
    );
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final body = json.decode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final token = body['token'];
      return (token is String && token.isNotEmpty) ? token : null;
    } catch (_) {
      return null;
    }
  }
}
