import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/features/products/presentation/screens/product_form_screen.dart';

class ProductFormRobot {
  ProductFormRobot(this.tester);

  final WidgetTester tester;

  // Finders
  Finder get screen => find.byType(ProductFormScreen);
  Finder get nameField => find.widgetWithText(TextFormField, 'Product Name *');
  Finder get priceField => find.widgetWithText(TextFormField, 'Price *');
  Finder get stockField => find.widgetWithText(TextFormField, 'Stock Quantity');
  Finder get categoryDropdown => find.byType(DropdownButtonFormField<String>);
  Finder get descriptionField => find.widgetWithText(TextFormField, 'Description');
  Finder get imageUrlField => find.widgetWithText(TextFormField, 'Image URL');
  Finder get submitButton => find.byType(FilledButton);
  Finder get appBarSaveButton => find.byIcon(Icons.check);
  Finder get loadingIndicator => find.byType(CircularProgressIndicator);
  Finder get errorContainer => find.byIcon(Icons.error_outline);

  Finder get createTitle => find.text('New Product');
  Finder get editTitle => find.text('Edit Product');
  Finder get createButtonText => find.text('Create Product');
  Finder get saveButtonText => find.text('Save Changes');
  Finder get successSnackbar => find.textContaining('successfully');

  Finder validationError(String error) => find.text(error);

  // Assertions
  Future<void> isVisible() async => expect(screen, findsOneWidget);

  Future<void> isCreateMode() async => expect(createTitle, findsOneWidget);

  Future<void> isEditMode() async => expect(editTitle, findsOneWidget);

  Future<void> showsLoading() async => expect(loadingIndicator, findsOneWidget);

  Future<void> showsError(String message) async => expect(find.text(message), findsOneWidget);

  Future<void> showsValidationError(String error) async => expect(validationError(error), findsOneWidget);

  Future<void> showsSuccessSnackbar() async => expect(successSnackbar, findsOneWidget);

  Future<void> isNotVisible() async => expect(screen, findsNothing);

  Future<void> hasNameValue(String value) async {
    final textField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Product Name *'));
    expect(textField.controller?.text, value);
  }

  Future<void> hasPriceValue(String value) async {
    final textField = tester.widget<TextFormField>(find.widgetWithText(TextFormField, 'Price *'));
    expect(textField.controller?.text, value);
  }

  // Actions
  Future<void> enterName(String name) async {
    await tester.enterText(nameField, name);
    await tester.pumpAndSettle();
  }

  Future<void> enterPrice(String price) async {
    await tester.enterText(priceField, price);
    await tester.pumpAndSettle();
  }

  Future<void> enterStock(String stock) async {
    await tester.enterText(stockField, stock);
    await tester.pumpAndSettle();
  }

  Future<void> enterDescription(String description) async {
    await tester.enterText(descriptionField, description);
    await tester.pumpAndSettle();
  }

  Future<void> enterImageUrl(String url) async {
    await tester.enterText(imageUrlField, url);
    await tester.pumpAndSettle();
  }

  Future<void> selectCategory(String category) async {
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(category).last);
    await tester.pumpAndSettle();
  }

  Future<void> tapSubmit() async {
    // Use appBar save button as it's always visible
    await tester.tap(appBarSaveButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapAppBarSave() async {
    await tester.tap(appBarSaveButton);
    await tester.pumpAndSettle();
  }

  Future<void> fillValidProductForm({
    String name = 'New Product',
    String price = '99.99',
    String stock = '10',
    String? category,
    String? description,
  }) async {
    await enterName(name);
    await enterPrice(price);
    await enterStock(stock);
    if (category case final category?) {
      await selectCategory(category);
    }
    if (description case final description?) {
      await enterDescription(description);
    }
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
