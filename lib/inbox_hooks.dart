import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

class SuprSendCubit extends Cubit<Map<String, dynamic>> {
  SuprSendCubit(Map<String, dynamic> initialState) : super(initialState);

  void editName(dynamic name) => emit({"name": name});
}

class SuprSendProvider extends StatelessWidget {
  final Widget child;

  const SuprSendProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SuprSendCubit({"name": "mike"}),
      child: child,
    );
  }
}

useCubeValue() {
  final cubit = useBloc<SuprSendCubit>();
  final state = useBlocBuilder(cubit, buildWhen: (state) => true);
  return state;
}
