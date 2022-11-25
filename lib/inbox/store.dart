import 'package:flutter_bloc/flutter_bloc.dart';

class SuprSendConfigCubit extends Cubit<Map<String, dynamic>> {
  SuprSendConfigCubit(String workspaceKey, String workspaceSecret,
      String? distinctId, String? subscriberId)
      : super({
          "workspaceKey": workspaceKey,
          "workspaceSecret": workspaceSecret,
          "distinctId": distinctId,
          "subscriberId": subscriberId,
          "collectorApiUrl": 'https://collector-staging.suprsend.workers.dev/',
          "apiUrl": 'https://collector-staging.suprsend.workers.dev/',
          "pollingInterval": 20 * 1000,
          "batchSize": 20,
          "batchTimeInterval": 30 * 24 * 60 * 60 * 1000
        });

  void editConfig(Map<String, dynamic> partialConfig) {
    emit({...state, ...partialConfig});
  }
}
