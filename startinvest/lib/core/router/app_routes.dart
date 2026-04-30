class AppRoutes {
  AppRoutes._();

  static const String signIn = '/sign-in';
  static const String home = '/home';
  static const String games = '/games';
  static const String content = '/content';
  static const String ranking = '/ranking';
  static const String news = '/news';
  static const String missions = '/missions';
  static const String course = '/content/course/:id';
  static const String lesson = '/content/course/:courseId/lesson/:lessonId';
  static const String article = '/content/article/:id';
  static const String quiz = '/games/quiz/:id';
  static const String portfolio = '/games/portfolio/:id';
  static const String profile = '/profile';
}
