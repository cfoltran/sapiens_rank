import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sapiens_rank/common/data_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateCubit extends Cubit<DataState<UpdateStatus>> {
  UpdateCubit() : super(const InitialDataState());

  final logger = Logger('UpdateCubit');

  Future<void> fetch() async {
    emit(const LoadingDataState());
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final response = await Supabase.instance.client.from('versions').select();
      final minVersion = response.first['version'] as String;
      final currentVersion = packageInfo.version;

      if (currentVersion.compareTo(minVersion) < 0) {
        emit(const SuccessDataState(UpdateStatus.needsUpdate));
        return;
      }

      emit(const SuccessDataState(UpdateStatus.upToDate));
    } catch (e) {
      logger.severe('Failed to load app version: $e');
      emit(ErrorDataState('Failed to load app version: $e'));
    }
  }
}

enum UpdateStatus { needsUpdate, loading, upToDate }
