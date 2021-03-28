part of 'quiz_bloc.dart';


abstract class QuizEvent {}

class QuizLoaded extends QuizEvent {
  final String bookId;

  QuizLoaded(this.bookId);
}