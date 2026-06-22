import 'market_question.dart';

class GameSession {
  final String id;
  final String difficulty; // easy, medium, hard
  final List<MarketQuestion> questions;
  final List<bool> answers; // true = sobe, false = desce
  final int currentQuestionIndex;
  final int totalPoints;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final bool isComplete;

  GameSession({
    required this.id,
    required this.difficulty,
    required this.questions,
    this.answers = const [],
    this.currentQuestionIndex = 0,
    this.totalPoints = 0,
    required this.startedAt,
    this.finishedAt,
    this.isComplete = false,
  });

  int get streak => _calculateStreak();
  int get maxStreakBonus => _getMaxStreakBonus();

  int _calculateStreak() {
    int count = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] == questions[i].correctAnswer) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  int _getMaxStreakBonus() {
    return switch (difficulty) {
      'easy' => 30,
      'medium' => 50,
      'hard' => 70,
      _ => 30,
    };
  }

  int calculatePointsForQuestion(int questionIndex) {
    final streakLength = questionIndex + 1;
    final multiplier = switch (difficulty) {
      'easy' => 5,
      'medium' => 10,
      'hard' => 15,
      _ => 5,
    };
    return (streakLength * multiplier).clamp(0, maxStreakBonus);
  }

  GameSession copyWith({
    String? id,
    String? difficulty,
    List<MarketQuestion>? questions,
    List<bool>? answers,
    int? currentQuestionIndex,
    int? totalPoints,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool? isComplete,
  }) {
    return GameSession(
      id: id ?? this.id,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      totalPoints: totalPoints ?? this.totalPoints,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}
