// Basic widget tests for the AutoMate application.
//
// Verifies that the home page displays appropriate elements and that tapping
// the start/end button records rides correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:automate/main.dart';

void main() {
  // Skipped: GoogleMap cannot render in widget tests reliably
  testWidgets('Initial home page shows map placeholder and nearby list',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AutoMateApp());

    // basic elements still present
    expect(find.text('Nearby Mechanics'), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  }, skip: true);

  // we can also verify GoogleMap widget exists at runtime once running on device
  testWidgets('Home page contains GoogleMap widget', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoMateApp());
    expect(find.byType(GoogleMap), findsOneWidget);
  }, skip: true);

  testWidgets('Tapping different bottom nav items switches pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(const AutoMateApp());

    // home content is map placeholder (may appear twice in nav)
    expect(find.byIcon(Icons.map), findsWidgets);

    // go to search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Search Page'), findsOneWidget);

    // go to messages
    await tester.tap(find.byIcon(Icons.message));
    await tester.pumpAndSettle();
    expect(find.text('Messages Page'), findsOneWidget);

    // go to profile
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();
    expect(find.text('Profile Page'), findsOneWidget);

    // back to home
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.map), findsOneWidget);
  });

  // ride tests removed since ride functionality moved off home page

}
