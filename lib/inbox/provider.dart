import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';
import './utils.dart';

class SuprSendProvider extends HookWidget {
  final Widget child;
  final String workspaceKey;
  final String workspaceSecret;
  dynamic distinctId;
  String? subscriberId;

  SuprSendProvider(
      {Key? key,
      required this.child,
      required this.workspaceKey,
      required this.workspaceSecret,
      this.distinctId,
      this.subscriberId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuprSendStoreCubit(
          workspaceKey, workspaceSecret, distinctId, subscriberId),
      child: SuprSendWithStore(
          child: child, distinctId: distinctId, subscriberId: subscriberId),
    );
  }
}

class SuprSendWithStore extends HookWidget {
  final Widget child;
  dynamic distinctId;
  String? subscriberId;

  SuprSendWithStore(
      {Key? key, required this.child, this.distinctId, this.subscriberId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeCubit = useBloc<SuprSendStoreCubit>(closeOnDispose: false);
    final storeData = useBlocBuilder(storeCubit);
    final configData = storeData["config"];

    handleSubscriberChange({String? distinctId, String? subscriberId}) async {
      final storedData =
          await getClientNotificationStorage(configData["storage_key"]);

      if (storedData != null && storedData["subscriberId"] == subscriberId) {
        storeCubit.updateNotifData({
          "notifications": storedData["notifications"],
          "unSeenCount": 0,
          "lastFetchedOn": null,
          "firstFetchedOn": null,
          "pollingTimerId": null
        });
      } else {
        storeCubit.updateNotifData({
          "notifications": [],
          "unSeenCount": 0,
          "lastFetchedOn": null,
          "firstFetchedOn": null,
          "pollingTimerId": null
        });
      }
      if (subscriberId != null && subscriberId != '') {
        storeCubit.updateConfig(
            {"distinctId": distinctId, "subscriberId": subscriberId});
        storeCubit.fetchNotifications();
      }
    }

    useEffect(() {
      handleSubscriberChange(
        distinctId: distinctId,
        subscriberId: subscriberId,
      );
      return storeCubit.clearPolling;
    }, [subscriberId]);

    return child;
  }
}
