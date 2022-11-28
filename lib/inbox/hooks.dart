import 'package:hooked_bloc/hooked_bloc.dart';
import './store.dart';

useSuprSendStore() {
  final cubit = useBloc<SuprSendStoreCubit>();
  final state = useBlocBuilder(cubit, buildWhen: (state) => true);
  return state;
}
