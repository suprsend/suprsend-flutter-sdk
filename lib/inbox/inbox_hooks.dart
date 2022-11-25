import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';

class SuprSendProvider extends HookWidget {
  final Widget child;
  final String workspaceKey;
  final String workspaceSecret;
  final String distinctId;
  final String subscriberId;

  const SuprSendProvider(
      {Key? key,
      required this.child,
      required this.workspaceKey,
      required this.workspaceSecret,
      required this.distinctId,
      required this.subscriberId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuprSendConfigCubit(
          workspaceKey, workspaceSecret, distinctId, subscriberId),
      child: child,
    );
  }
}

useCubeValue() {
  final cubit = useBloc<SuprSendConfigCubit>();
  final state = useBlocBuilder(cubit, buildWhen: (state) => true);
  return state;
}
