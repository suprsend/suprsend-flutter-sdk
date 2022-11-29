import 'package:uuid/uuid.dart';

String uuid() {
  var uuid = const Uuid();
  return uuid.v4();
}

int epochNow() {
  return DateTime.now().millisecondsSinceEpoch;
}
