class MarketQuestion {
  final String id;
  final String story;
  final String company;
  final bool correctAnswer; // true = sobe, false = desce
  final String difficulty; // easy, medium, hard
  final String? explanation;

  MarketQuestion({
    required this.id,
    required this.story,
    required this.company,
    required this.correctAnswer,
    required this.difficulty,
    this.explanation,
  });
}
