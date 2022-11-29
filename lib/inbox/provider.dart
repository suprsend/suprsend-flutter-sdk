import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';

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
    final storeCubit = useBloc<SuprSendStoreCubit>();
    final storeData = useBlocBuilder(storeCubit);
    final notifData = storeData["notifData"];

    useEffect(() {
      if (subscriberId != null && notifData["lastFetchedOn"] == null) {
        storeCubit.updateConfig(
            {"distinctId": distinctId, "subscriberId": subscriberId});
        storeCubit.fetchNotifications();
      }
      return storeCubit.clearPolling;
    }, [subscriberId]);

    return child;
  }
}
