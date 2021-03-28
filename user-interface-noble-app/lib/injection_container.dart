import 'package:get_it/get_it.dart';
import 'package:mds_reads/pages/config/cubit/config_cubit.dart';
import 'package:mds_reads/pages/config/data/datasource/config_datasource.dart';
import 'package:mds_reads/pages/config/data/repository/config_repository.dart';
import 'package:mds_reads/pages/quiz/controllers/quiz_bloc/quiz_bloc.dart';
import 'package:mds_reads/pages/quiz/data/datasources/quiz_datasource.dart';
import 'package:mds_reads/pages/quiz/data/repositories/quiz_repository.dart';

final getIt = GetIt.instance;

void setupInjections() {

  getIt.registerLazySingleton<QuizRemoteDataSource>(
        () => QuizRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<QuizRepository>(
        () => QuizRepositoryImpl(getIt()),
  );

  getIt.registerFactory<QuizBloc>(
        () => QuizBloc(getIt()),
  );

  getIt.registerLazySingleton<ConfigRemoteDataSource>(
        () => ConfigRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<ConfigRepository>(
        () => ConfigRepositoryImpl(getIt()),
  );

  getIt.registerFactory<ConfigCubit>(
        () => ConfigCubit(getIt()),
  );

}
