import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gajacash_sample/features/onboarding/screens/verification_code_screen.dart';
import 'package:gajacash_sample/core/theme.dart';

void main() {
  testWidgets('VerificationCodeScreen fits 5-inch screen (360x640) without scrolling', (WidgetTester tester) async {
    // Set viewport size to 360x640 (standard 5-inch screen metrics)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    
    // Reset sizes after the test finishes
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Pump the VerificationCodeScreen inside a MaterialApp with AppTheme
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const VerificationCodeScreen(phoneNumber: "+94777123456"),
      ),
    );

    // Let the initial animations or timers settle
    await tester.pumpAndSettle();

    // Verify there are no overflow errors on screen
    expect(tester.takeException(), isNull);

    // Find the vertical Scrollable widget inside CustomScrollView
    final scrollableFinder = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down),
    );
    expect(scrollableFinder, findsOneWidget);

    final ScrollableState scrollableState = tester.state(scrollableFinder);
    final maxScrollExtent = scrollableState.position.maxScrollExtent;
    
    debugPrint("Max scroll extent for 360x640: $maxScrollExtent");
    
    // Assert that the maxScrollExtent is 0.0, meaning no scrolling is needed
    expect(maxScrollExtent, 0.0, reason: "The screen content should fit without scrolling");
  });

  testWidgets('VerificationCodeScreen fits 4-inch screen (320x568) without scrolling', (WidgetTester tester) async {
    // Set viewport size to 320x568 (standard 4-inch screen metrics)
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    
    // Reset sizes after the test finishes
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Pump the VerificationCodeScreen inside a MaterialApp with AppTheme
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const VerificationCodeScreen(phoneNumber: "+94777123456"),
      ),
    );

    // Let the initial animations or timers settle
    await tester.pumpAndSettle();

    // Verify there are no overflow errors on screen
    expect(tester.takeException(), isNull);

    // Find the vertical Scrollable widget inside CustomScrollView
    final scrollableFinder = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byWidgetPredicate((widget) => widget is Scrollable && widget.axisDirection == AxisDirection.down),
    );
    expect(scrollableFinder, findsOneWidget);

    final ScrollableState scrollableState = tester.state(scrollableFinder);
    final maxScrollExtent = scrollableState.position.maxScrollExtent;
    
    debugPrint("Max scroll extent for 320x568: $maxScrollExtent");
    
    // Assert that the maxScrollExtent is 0.0, meaning no scrolling is needed
    expect(maxScrollExtent, 0.0, reason: "The screen content should fit without scrolling");
  });
}
