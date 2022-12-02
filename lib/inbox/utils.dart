import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String uuid() {
  var uuid = const Uuid();
  return uuid.v4();
}

int epochNow() {
  return DateTime.now().millisecondsSinceEpoch;
}

String utcNow() {
  return DateTime.now().toString();
}

createSignature(
    {workspaceSecret, route, dynamic body, method, contentType = '', date}) {
  String md5String = '';
  if (body != null) {
    md5String = md5.convert(utf8.encode(body)).toString();
  }
  final message = "$method\n$md5String\n$contentType\n$date\n$route";
  final key = utf8.encode(workspaceSecret);
  final bytes = utf8.encode(message);
  final hmacSha256 = Hmac(sha256, key).convert(bytes).bytes;
  return base64Encode(hmacSha256);
}

setStorage(String key, value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

getStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

// getStorageKey(String key) {
//   String newStr = '';
//   for (int i = 0; i < key.length; i = i + 2) {
//     newStr += key[i].toLowerCase();
//   }
//   return "_suprsend_inbox_$newStr";
// }

getClientNotificationStorage(String key) async {
  final value = await getStorage(key);
  return value != null ? json.decode(value) : null;
}

setClientNotificationStorage(String key, value) async {
  await setStorage(key, jsonEncode(value));
}
