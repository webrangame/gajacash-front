import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gajacash_sample/main.dart';

void main() {
  testWidgets('GajaCash app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const GajaCashApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
