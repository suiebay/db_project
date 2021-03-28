import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:mds_reads/globals.dart' as globals;

abstract class QuizRemoteDataSource {
  Future<Response> getQuiz(String bookId);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  Box box = Hive.box('config');
  Dio dio = Dio();

  @override
  Future<Response> getQuiz(String bookId) async {
    dio.options.headers["authorization"] = "Bearer ${globals.accessTokenG}";

    Response response = await dio.get('${box.get('url')}/api/project/reads/quiz/generation/$bookId');

    return response;
  }
}