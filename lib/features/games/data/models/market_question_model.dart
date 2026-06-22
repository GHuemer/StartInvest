import '../../../games/domain/entities/market_question.dart';

class MarketQuestionModel extends MarketQuestion {
  MarketQuestionModel({
    required super.id,
    required super.story,
    required super.company,
    required super.correctAnswer,
    required super.difficulty,
    super.explanation,
  });

  factory MarketQuestionModel.fromMap(Map<String, dynamic> map) {
    return MarketQuestionModel(
      id: map['id'] as String,
      story: map['story'] as String,
      company: map['company'] as String,
      correctAnswer: map['correctAnswer'] as bool,
      difficulty: map['difficulty'] as String,
      explanation: map['explanation'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'story': story,
      'company': company,
      'correctAnswer': correctAnswer,
      'difficulty': difficulty,
      'explanation': explanation,
    };
  }
}
