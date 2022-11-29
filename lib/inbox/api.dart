import 'dart:convert';

import 'package:http/http.dart' as http;
import "./utils.dart";

class ApiClient {
  getNotifications(dynamic config, num after, num? before) async {
    final queryParams = {
      "subscriber_id": config["subscriberId"],
      "distinct_id": config["distinctId"],
      "after": after.toString(),
    };
    if (before != null) {
      queryParams["before"] = before;
    }
    const signature = "hjhjhjhjh"; // implement signature
    final urlIs = Uri.https(config["apiUrl"], "inbox/fetch", queryParams);
    final response = await http.get(urlIs, headers: {
      "Authorization": "${config["workspaceKey"]}:$signature",
      'x-amz-date': epochNow().toString(),
    });
    return response;
  }

  markNotificationClicked(dynamic config, String id) async {
    final body = {
      "event": "\$notification_clicked",
      "env": config["workspaceKey"],
      "\$insert_id": uuid(),
      "\$time": epochNow().toString(),
      "properties": {"id": id}
    };
    final urlIs = Uri.https(
      config["collectorApiUrl"],
      "event/",
    );
    final response = await http
        .post(urlIs, body: jsonEncode(<String, dynamic>{...body}), headers: {
      "Authorization": "${config["workspaceKey"]}:",
      'Content-Type': 'application/json',
      'x-amz-date': epochNow().toString(),
    });
    return response;
  }

  markBellClicked(dynamic config) async {
    const String route = '/bell-clicked/';
    final date = epochNow().toString();
    final body = jsonEncode(<String, dynamic>{
      "time": epochNow(),
      "distinct_id": config["distinctId"],
      "subscriber_id": config["subscriberId"]
    });
    const signature = "hjhjhjhjh"; // implement signature
    final urlIs = Uri.https(
      config["apiUrl"],
      "/inbox$route",
    );

    final response = await http.post(urlIs, body: body, headers: {
      "Authorization": "${config["workspaceKey"]}:$signature",
      'Content-Type': 'application/json',
      'x-amz-date': date,
    });
    return response;
  }
}
