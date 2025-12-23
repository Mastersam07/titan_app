import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/models/product.dart';
import 'package:titan_flutter/ui/screens/product_form_screen.dart';

void main() {
  const testProduct = Product(
    id: 1,
    name: 'Test Product',
    description: 'A test product description',
    price: 99.99,
    imageUrl: 'https://example.com/image.jpg',
    stockQuantity: 10,
    category: 'Electronics',
  );

  Widget createWidgetUnderTest({Product? product}) {
    return MaterialApp(
      home: ProductFormScreen(product: product),
    );
  }

  group('ProductFormScreen', () {
    group('Create mode', () {
      testWidgets('displays "New Product" title when creating', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('New Product'), findsOneWidget);
      });

      testWidgets('displays empty form fields when creating', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Name field should exist
        expect(find.text('Product Name *'), findsOneWidget);
        
        // Price field should exist
        expect(find.text('Price *'), findsOneWidget);
      });

      testWidgets('displays "Create Product" button when creating', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Scroll to bottom to find the button
        await tester.dragUntilVisible(
          find.text('Create Product'),
          find.byType(ListView),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();

        expect(find.text('Create Product'), findsOneWidget);
      });

      testWidgets('validates required name field on submit', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter only price (leave name empty)
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Price *'),
          '10.00',
        );

        // Scroll to and tap submit button
        await tester.dragUntilVisible(
          find.text('Create Product'),
          find.byType(ListView),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Create Product'));
        await tester.pumpAndSettle();

        // Scroll back up to see validation error
        await tester.dragUntilVisible(
          find.text('Product name is required'),
          find.byType(ListView),
          const Offset(0, 100),
        );
        await tester.pumpAndSettle();

        expect(find.text('Product name is required'), findsOneWidget);
      });

      testWidgets('validates required price field on submit', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter only name (leave price empty)
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Product Name *'),
          'Test Product',
        );

        // Scroll to and tap submit button
        await tester.dragUntilVisible(
          find.text('Create Product'),
          find.byType(ListView),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Create Product'));
        await tester.pumpAndSettle();

        expect(find.text('Price is required'), findsOneWidget);
      });
    });

    group('Edit mode', () {
      testWidgets('displays "Edit Product" title when editing', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(product: testProduct));

        expect(find.text('Edit Product'), findsOneWidget);
      });

      testWidgets('pre-fills name field with product data', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(product: testProduct));
        await tester.pumpAndSettle();

        // Check that the name field contains the product name
        expect(find.text('Test Product'), findsOneWidget);
      });

      testWidgets('pre-fills price field with product data', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(product: testProduct));
        await tester.pumpAndSettle();

        expect(find.text('99.99'), findsOneWidget);
      });

      testWidgets('displays "Save Changes" button when editing', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(product: testProduct));

        // Scroll to bottom to find the button
        await tester.dragUntilVisible(
          find.text('Save Changes'),
          find.byType(ListView),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();

        expect(find.text('Save Changes'), findsOneWidget);
      });
    });

    group('Form fields', () {
      testWidgets('displays all form fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Product Name *'), findsOneWidget);
        expect(find.text('Price *'), findsOneWidget);
        expect(find.text('Stock Quantity'), findsOneWidget);
        expect(find.text('Category'), findsOneWidget);
      });

      testWidgets('displays description field', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Scroll to find description
        await tester.dragUntilVisible(
          find.text('Description'),
          find.byType(ListView),
          const Offset(0, -50),
        );
        await tester.pumpAndSettle();

        expect(find.text('Description'), findsOneWidget);
      });

      testWidgets('displays image URL field', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Scroll to find image URL
        await tester.dragUntilVisible(
          find.text('Image URL'),
          find.byType(ListView),
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();

        expect(find.text('Image URL'), findsOneWidget);
      });

      testWidgets('has check icon in app bar', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('isEditing property', () {
      testWidgets('isEditing is false when product is null', (tester) async {
        const screen = ProductFormScreen();
        expect(screen.isEditing, false);
      });

      testWidgets('isEditing is true when product is provided', (tester) async {
        const screen = ProductFormScreen(product: testProduct);
        expect(screen.isEditing, true);
      });
    });
  });
}