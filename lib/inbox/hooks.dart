import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';

useBell() {
  final cubit = useBloc<SuprSendStoreCubit>(closeOnDispose: false);
  final state = useBlocBuilder(
    cubit,
    buildWhen: (current) {
      final state = current as Map;
      return state["rerender"] == true;
    },
  );

  return {
    "unSeenCount": state["notifData"]["unSeenCount"],
    "markAllSeen": cubit.markAllSeen
  };
}

useNotifications() {
  final cubit = useBloc<SuprSendStoreCubit>(closeOnDispose: false);
  final state = useBlocBuilder(
    cubit,
    buildWhen: (current) {
      final state = current as Map;
      return state["rerender"] == true;
    },
  );

  return {
    "notifications": state["notifData"]["notifications"],
    "unSeenCount": state["notifData"]["unSeenCount"],
    "markAllSeen": cubit.markAllSeen,
    "markClicked": cubit.markClicked,
  };
}

useNewNotificationListener(callback) {
  final cubit = useBloc<SuprSendStoreCubit>(closeOnDispose: false);
  useBlocListener(cubit, (_, value, context) {
    callback(cubit.latestNotifications);
    cubit.latestNotifications = [];
  }, listenWhen: (state) {
    return cubit.latestNotifications.isNotEmpty;
  });
}
