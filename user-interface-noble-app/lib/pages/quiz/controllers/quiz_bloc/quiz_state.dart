part of 'quiz_bloc.dart';

abstract class QuizState {}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizFailure extends QuizState {
  final String message;

  QuizFailure(this.message);
}

class QuizSuccess extends QuizState {
  final List<Quiz> quiz;

  QuizSuccess(this.quiz);
}
