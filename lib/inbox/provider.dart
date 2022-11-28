import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';
import "./hooks.dart";

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
      child: SuprSendWithStore(child: child),
    );
  }
}

class SuprSendWithStore extends HookWidget {
  final Widget child;

  const SuprSendWithStore({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storeCubit = useBloc<SuprSendStoreCubit>();
    final storeData = useSuprSendStore();
    final notifData = storeData["notifData"];
    final configData = storeData["config"];

    useEffect(() {
      if (configData["subscriberId"] != null &&
          notifData["lastFetchedOn"] == null) {
        storeCubit.fetchNotifications();
      }
      return storeCubit.clearPolling;
    }, [configData["subscriberId"]]);

    return child;
  }
}
