import 'package:flutter/services.dart' show MethodChannel;

class User {
  late MethodChannel channel;

  User(MethodChannel _channel) {
    channel = _channel;
  }

  void setEmail(String email) {
    channel.invokeMethod("setEmail", {"email": email});
  }

  void unSetEmail(String email) {
    channel.invokeMethod("unSetEmail", {"email": email});
  }

  void setSms(String mobile) {
    channel.invokeMethod("setSms", {"mobile": mobile});
  }

  void unSetSms(String mobile) {
    channel.invokeMethod("unSetSms", {"mobile": mobile});
  }

  void setWhatsApp(String mobile) {
    channel.invokeMethod("setWhatsApp", {"mobile": mobile});
  }

  void unSetWhatsApp(String mobile) {
    channel.invokeMethod("unSetWhatsApp", {"mobile": mobile});
  }

  void set(Map<String, Object?>? properties) {
    channel.invokeMethod("set", properties);
  }

  void setOnce(Map<String, Object?>? properties) {
    channel.invokeMethod("setOnce", properties);
  }

  void increment(Map<String, Object?>? properties) {
    channel.invokeMethod("increment", properties);
  }

  void append(Map<String, Object?>? properties) {
    channel.invokeMethod("append", properties);
  }

  void remove(Map<String, Object?>? properties) {
    channel.invokeMethod("remove", properties);
  }

  void unSet(List<String?> keys) {
    channel.invokeMethod("unSet", {"keys": keys});
  }
}
