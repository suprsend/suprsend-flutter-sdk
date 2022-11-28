import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert' as convert;
import './api.dart';

// contains config related info
class SuprSendStoreCubit extends Cubit<Map<String, dynamic>> {
  SuprSendStoreCubit(String workspaceKey, String workspaceSecret,
      String? distinctId, String? subscriberId)
      : super({
          "config": {
            "workspaceKey": workspaceKey,
            "workspaceSecret": workspaceSecret,
            "distinctId": distinctId,
            "subscriberId": subscriberId,
            "collectorApiUrl": 'collector-staging.suprsend.workers.dev',
            "apiUrl": 'collector-staging.suprsend.workers.dev',
            "pollingInterval": 20,
            "batchSize": 20,
            "batchTimeInterval": 30 * 24 * 60 * 60 * 1000
          },
          "notifData": {
            "notifications": [],
            "unSeenCount": 0,
            "lastFetchedOn": null,
            "firstFetchedOn": null,
            "pollingTimerId": null
          }
        });

  void updateConfig(Map<String, dynamic> newData) {
    emit({
      ...state,
      "config": {...state["config"], ...newData}
    });
  }

  void updateNotifData(Map<String, dynamic> newData) {
    emit({
      ...state,
      "notifData": {...state["notifData"], ...newData}
    });
  }

  void clearPolling() {
    final notifData = state["notifData"];
    final pollingTimerId = notifData["pollingTimerId"];
    updateNotifData({"lastFetchedOn": null, "firstFetchedOn": null});
    pollingTimerId.cancel();
  }

  fetchNotifications() async {
    final configData = state["config"];
    final notifData = state["notifData"];
    final isFirstCall = notifData["lastFetchedOn"] == null;
    final currentTimeStamp = DateTime.now().millisecondsSinceEpoch;
    final prevMonthTimeStamp =
        currentTimeStamp - configData["batchTimeInterval"];
    final currentFetchFrom = notifData["lastFetchedOn"] ?? prevMonthTimeStamp;

    try {
      final response = await ApiClient()
          .getNotifications(state["config"], currentFetchFrom, null);
      if (response.statusCode == 200) {
        final respData = convert.jsonDecode(response.body);
        print("GOT NEW NOTIFICATIONS ${respData["unread"]}");
        final newNotifications = isFirstCall
            ? [...respData["results"]]
            : [...respData["results"], ...notifData["notifications"]];

        updateNotifData({
          "notifications": newNotifications,
          "unSeenCount": notifData["unSeenCount"] + respData["unread"],
          "lastFetchedOn": currentTimeStamp,
          "firstFetchedOn":
              isFirstCall ? prevMonthTimeStamp : notifData["firstFetchedOn"]
        });
      }
    } catch (e) {
      print('SUPRSEND2: error getting latest notifications ${e.toString()}');
    }
    var duration = Duration(seconds: configData["pollingInterval"]);
    var timerId = Timer(duration, () => {fetchNotifications()});
    updateNotifData({"pollingTimerId": timerId});
  }
}
