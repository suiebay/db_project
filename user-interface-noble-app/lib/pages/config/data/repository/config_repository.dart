import 'package:dio/dio.dart';
import 'package:mds_reads/pages/config/data/datasource/config_datasource.dart';
import 'package:mds_reads/pages/config/data/model/config.dart';

abstract class ConfigRepository {
  Future<List<Config>> getConfig();
}

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigRemoteDataSource configRemoteDataSource;

  ConfigRepositoryImpl(this.configRemoteDataSource);

  @override
  Future<List<Config>> getConfig() async {
    Response response = await configRemoteDataSource.getConfig();
    return (response.data as List)
        .map((object) => Config.fromJson(object))
        .toList();
  }
}