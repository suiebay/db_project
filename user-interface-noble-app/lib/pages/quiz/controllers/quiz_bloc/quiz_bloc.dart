import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mds_reads/pages/quiz/data/models/quiz.dart';
import 'package:mds_reads/pages/quiz/data/repositories/quiz_repository.dart';

part 'quiz_state.dart';
part 'quiz_event.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository quizRepository;

  QuizBloc(this.quizRepository) : super(QuizInitial());

  @override
  Stream<QuizState> mapEventToState(
    QuizEvent event
  ) async* {
    if(event is QuizLoaded) {
      yield* _mapQuizLoadedToState(event, state);
    }
  }

  Stream<QuizState> _mapQuizLoadedToState (
      QuizLoaded event,
      QuizState state
      ) async* {
    yield QuizLoading();
    try {
      final List<Quiz> products = await quizRepository.getQuiz(event.bookId);

      yield QuizSuccess(products);
    } on Exception catch (e) {
      yield QuizFailure(e.toString());
      throw e;
    }
  }
}