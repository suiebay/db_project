import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mds_reads/pages/config/data/model/config.dart';
import 'package:mds_reads/pages/config/data/repository/config_repository.dart';

part 'config_state.dart';

class ConfigCubit extends Cubit<ConfigState> {
  final ConfigRepository configRepository;

  ConfigCubit(this.configRepository) : super(ConfigInitial());

  Future<void> getConfig() async {
    emit(ConfigLoading());
    try {
      final List<Config> products = await configRepository.getConfig();

      emit(ConfigSuccess(products));
    } on Exception catch (e) {
      emit(ConfigFailure(e.toString()));
      throw e;
    }
  }
}