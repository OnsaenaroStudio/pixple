import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pixple/main.dart';

void main() {
  testWidgets('앱 시작 시 알레르기 검사 화면이 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixpleApp()));
    await tester.pumpAndSettle();

    expect(find.text('알레르기 검사'), findsOneWidget);
  });

  testWidgets('하단 퀵 메뉴 4개 버튼이 모두 표시된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixpleApp()));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.eco), findsOneWidget);
    expect(find.byIcon(Icons.menu_book), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
  });

  testWidgets('퀵 메뉴 탭 전환이 정상 동작한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixpleApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.pumpAndSettle();
    expect(find.text('음식 레시피'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    expect(find.text('남은 음식 레시피'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
  });

  testWidgets('카메라 버튼 탭 시 레시피 결과 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixpleApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('클릭해서 사진 찍기'));
    await tester.pumpAndSettle();

    expect(find.text('레시피'), findsOneWidget);
    expect(find.text('뒤로가기'), findsOneWidget);
  });

  testWidgets('레시피 결과 화면에서 뒤로가기 버튼이 동작한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixpleApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('클릭해서 사진 찍기'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('뒤로가기'));
    await tester.pumpAndSettle();

    expect(find.text('알레르기 검사'), findsOneWidget);
  });

  testWidgets('커뮤니티에서 글쓰기 화면으로 이동한다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PixpleApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chat_bubble_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.text('글 쓰기'));
    await tester.pumpAndSettle();

    expect(find.text('글 제목'), findsOneWidget);
    expect(find.text('글 내용'), findsOneWidget);
    expect(find.text('# 해시 태그 입력'), findsOneWidget);
  });
}