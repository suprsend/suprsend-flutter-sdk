import 'package:http/http.dart' as http;

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
      'x-amz-date': DateTime.now().millisecondsSinceEpoch.toString()
    });
    return response;
  }
}
