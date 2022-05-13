import 'package:flutter/services.dart' show MethodChannel;

class User {
  late MethodChannel channel;

  User(MethodChannel _channel) {
    channel = _channel;
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
