import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/features/products/presentation/screens/product_detail_screen.dart';

class ProductDetailRobot {
  ProductDetailRobot(this.tester);

  final WidgetTester tester;

  // Finders
  Finder get screen => find.byType(ProductDetailScreen);
  Finder get editButton => find.byIcon(Icons.edit);
  Finder get deleteButton => find.byIcon(Icons.delete);
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get deleteDialog => find.byType(AlertDialog);
  Finder get confirmDeleteButton => find.widgetWithText(FilledButton, 'Delete');
  Finder get cancelDeleteButton => find.widgetWithText(TextButton, 'Cancel');
  Finder get successSnackbar => find.text('Product deleted successfully');

  Finder productName(String name) => find.text(name);
  Finder productPrice(String price) => find.text(price);
  Finder productDescription(String description) => find.text(description);
  Finder productCategory(String category) => find.text(category);

  // Assertions
  Future<void> isVisible() async => expect(screen, findsOneWidget);

  Future<void> showsLoading() async => expect(loadingIndicator, findsOneWidget);

  Future<void> showsProductName(String name) async => expect(productName(name), findsOneWidget);

  Future<void> showsProductPrice(String price) async => expect(productPrice(price), findsOneWidget);

  Future<void> showsProductDescription(String description) async =>
      expect(productDescription(description), findsWidgets);

  Future<void> showsProductCategory(String category) async => expect(productCategory(category), findsWidgets);

  Future<void> showsDeleteDialog() async => expect(deleteDialog, findsOneWidget);

  Future<void> showsSuccessSnackbar() async => expect(successSnackbar, findsOneWidget);

  Future<void> isNotVisible() async => expect(screen, findsNothing);

  // Actions
  Future<void> tapEditButton() async {
    await tester.tap(editButton.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapDeleteButton() async {
    await tester.tap(deleteButton.first);
    await tester.pumpAndSettle();
  }

  Future<void> confirmDelete() async {
    await tester.tap(confirmDeleteButton);
    await tester.pumpAndSettle();
  }

  Future<void> cancelDelete() async {
    await tester.tap(cancelDeleteButton);
    await tester.pumpAndSettle();
  }

  Future<void> goBack() async {
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
    } else {
      await tester.pageBack();
    }
    await tester.pumpAndSettle();
  }
}
