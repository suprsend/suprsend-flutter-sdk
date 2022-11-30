import 'dart:convert';
import 'package:http/http.dart' as http;
import "./utils.dart";

class ApiClient {
  getNotifications(dynamic config, num after, num? before) async {
    final date = utcNow();
    String fullRoute =
        "/fetch/?subscriber_id=${config["subscriberId"]}&after=$after&distinct_id=${config["distinctId"]}";
    if (before != null) {
      fullRoute += "&before=${before.toString()}";
    }
    final signature = createSignature(
        workspaceSecret: config["workspaceSecret"],
        route: fullRoute,
        date: date,
        method: "GET");
    final urlIs = Uri.parse(config["apiUrl"] + fullRoute);
    final response = await http.get(urlIs, headers: {
      "Authorization": "${config["workspaceKey"]}:$signature",
      'x-amz-date': date,
    });
    return response;
  }

  markNotificationClicked(dynamic config, String id) async {
    final body = {
      "event": "\$notification_clicked",
      "env": config["workspaceKey"],
      "\$insert_id": uuid(),
      "\$time": epochNow(),
      "properties": {"id": id}
    };
    final urlIs = Uri.parse(config["collectorApiUrl"] + "/event/");
    final response = await http
        .post(urlIs, body: jsonEncode(<String, dynamic>{...body}), headers: {
      "Authorization": "${config["workspaceKey"]}:",
      'Content-Type': 'application/json',
      'x-amz-date': utcNow(),
    });
    return response;
  }

  markBellClicked(dynamic config) async {
    const String route = '/bell-clicked/';
    final date = utcNow();
    final body = jsonEncode(<String, dynamic>{
      "time": epochNow(),
      "distinct_id": config["distinctId"],
      "subscriber_id": config["subscriberId"]
    });
    final signature = createSignature(
        workspaceSecret: config["workspaceSecret"],
        route: route,
        date: date,
        method: "POST",
        body: body,
        contentType: "application/json; charset=utf-8");
    final urlIs = Uri.parse(config["apiUrl"] + route);
    final response = await http.post(urlIs, body: body, headers: {
      "Authorization": "${config["workspaceKey"]}:$signature",
      'Content-Type': 'application/json; charset=utf-8',
      'x-amz-date': date,
    });
    return response;
  }
}
