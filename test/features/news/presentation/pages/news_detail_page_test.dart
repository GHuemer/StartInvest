import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:startinvest/features/news/domain/entities/news_entry.dart';
import 'package:startinvest/features/news/presentation/pages/news_page.dart';

void main() {
  final mockNews = NewsEntry(
    id: '1',
    title: 'Test News Title',
    content: 'This is a test content for the news detail page.',
    date: '10 Jun 2026',
    source: 'InfoMoney',
    tag: 'Economia',
    category: 'economy',
  );

  group('NewsDetailPage Widget Tests', () {
    testWidgets('should render news details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NewsDetailPage(news: mockNews),
        ),
      );

      expect(find.text('Test News Title'), findsOneWidget);
      expect(find.text('This is a test content for the news detail page.'), findsOneWidget);
      expect(find.text('InfoMoney'), findsOneWidget);
      expect(find.text('Economia'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show correct category icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NewsDetailPage(news: mockNews),
        ),
      );

      // 'economy' category should show Icons.public
      expect(find.byIcon(Icons.public), findsOneWidget);
    });
  });
}
