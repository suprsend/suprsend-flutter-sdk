import 'dart:convert';

import 'package:http/http.dart' as http;

/// Fetches a SuprSend user token (JWT) from your backend.
///
/// In a real app this endpoint would be authenticated (e.g. behind your
/// session cookie / bearer token) and return a short-lived JWT signed with your
/// SuprSend workspace secret. Here it's a plain demo endpoint:
///
///   GET {baseUrl}/authentication-token/{distinctId}  ->  { "token": "<jwt>" }
class AuthTokenService {
  const AuthTokenService(this.baseUrl);

  /// Base URL of your token endpoint, e.g. `http://192.168.4.239:8787`.
  /// Configured via `SUPRSEND_AUTH_TOKEN_URL` in `.env`.
  final String baseUrl;

  bool get isConfigured => baseUrl.isNotEmpty;

  /// Returns the user token for [distinctId], or `null` if it can't be fetched.
  Future<String?> fetchUserToken(String distinctId) async {
    if (!isConfigured) return null;
    final uri = Uri.parse(
      '$baseUrl/authentication-token/${Uri.encodeComponent(distinctId)}',
    );
    print('dart-Url:\n$uri');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return null;
      final body = json.decode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final token = body['token'];
      return (token is String && token.isNotEmpty) ? token : null;
    } catch (_) {
      // Network / parse errors -> caller decides how to proceed (e.g. identify
      // without a token, or let the SDK retry the refresh).
      return null;
    }
  }
}
