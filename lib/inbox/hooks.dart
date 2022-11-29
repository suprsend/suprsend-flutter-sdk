import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';

useBell() {
  final cubit = useBloc<SuprSendStoreCubit>();
  final state = useBlocBuilder(cubit);

  return {
    "unSeenCount": state["notifData"]["unSeenCount"],
    "markAllSeen": cubit.markAllSeen
  };
}

useNotifications() {
  final cubit = useBloc<SuprSendStoreCubit>();
  final state = useBlocBuilder(cubit);

  return {
    "notifications": state["notifData"]["notifications"],
    "unSeenCount": state["notifData"]["unSeenCount"],
    "markAllSeen": cubit.markAllSeen,
    "markClicked": cubit.markClicked,
  };
}
