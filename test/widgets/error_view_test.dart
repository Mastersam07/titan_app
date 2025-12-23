import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/ui/widgets/error_view.dart';

void main() {
  group('ErrorView', () {
    testWidgets('displays error message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Something went wrong'),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('displays error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays title text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error'),
          ),
        ),
      );

      expect(find.text('Oops! Something went wrong'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('hides retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorView(message: 'Error'),
          ),
        ),
      );

      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('calls onRetry when retry button is pressed', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorView(
              message: 'Error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(retried, true);
    });
  });

  group('EmptyView', () {
    testWidgets('displays default message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('displays custom message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(message: 'No products available'),
          ),
        ),
      );

      expect(find.text('No products available'), findsOneWidget);
    });

    testWidgets('displays default icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(icon: Icons.shopping_cart_outlined),
          ),
        ),
      );

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('shows action button when onAction and actionLabel provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              onAction: () {},
              actionLabel: 'Refresh',
            ),
          ),
        ),
      );

      expect(find.text('Refresh'), findsOneWidget);
    });

    testWidgets('hides action button when onAction is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyView(actionLabel: 'Refresh'),
          ),
        ),
      );

      expect(find.text('Refresh'), findsNothing);
    });

    testWidgets('hides action button when actionLabel is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(onAction: () {}),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('calls onAction when action button is pressed', (tester) async {
      var actionCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyView(
              onAction: () => actionCalled = true,
              actionLabel: 'Refresh',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      expect(actionCalled, true);
    });
  });
}
