import 'package:dio/dio.dart';

abstract class ConfigRemoteDataSource {
  Future<Response> getConfig();
}

class ConfigRemoteDataSourceImpl implements ConfigRemoteDataSource {
  Dio dio = Dio(BaseOptions(baseUrl: 'https://factory.mdsp.kz/api/clients/list'));

  @override
  Future<Response> getConfig() async {

    Response response = await dio.get('');

    return response;
  }
}