import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mds_reads/pages/quiz/data/datasources/quiz_datasource.dart';
import 'package:mds_reads/pages/quiz/data/models/quiz.dart';

abstract class QuizRepository {
  Future<List<Quiz>> getQuiz(String bookId);
}

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource quizRemoteDataSource;

  QuizRepositoryImpl(this.quizRemoteDataSource);

  @override
  Future<List<Quiz>> getQuiz(String bookId) async {
    Response response = await quizRemoteDataSource.getQuiz(bookId);
    return (response.data as List)
        .map((object) => Quiz.fromJson(object))
        .toList();
  }
}