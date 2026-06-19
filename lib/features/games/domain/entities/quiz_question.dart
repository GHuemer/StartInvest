class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

enum QuizDifficulty { conservative, moderate, aggressive }

class Quiz {
  final String id;
  final String title;
  final String description;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;
  final String iconPath;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.questions,
    required this.iconPath,
  });
}
