class GameResult {
  final String sessionId;
  final String difficulty;
  final int totalPoints;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracy;
  final DateTime completedAt;
  final int bestStreak;

  GameResult({
    required this.sessionId,
    required this.difficulty,
    required this.totalPoints,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracy,
    required this.completedAt,
    required this.bestStreak,
  });

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'difficulty': difficulty,
      'totalPoints': totalPoints,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'accuracy': accuracy,
      'completedAt': completedAt.toIso8601String(),
      'bestStreak': bestStreak,
    };
  }
}
