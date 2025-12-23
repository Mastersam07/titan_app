import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/models/product.dart';
import 'package:titan_flutter/ui/widgets/product_card.dart';

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

  const outOfStockProduct = Product(
    id: 2,
    name: 'Out of Stock Product',
    price: 49.99,
    stockQuantity: 0,
    category: 'Furniture',
  );

  const noImageProduct = Product(
    id: 3,
    name: 'No Image Product',
    price: 29.99,
  );

  Widget createWidgetUnderTest(
    Product product, {
    VoidCallback? onTap,
    VoidCallback? onEdit,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 300,
          child: ProductCard(
            product: product,
            onTap: onTap,
            onEdit: onEdit,
          ),
        ),
      ),
    );
  }

  group('ProductCard', () {
    testWidgets('displays product name', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProduct));
      await tester.pump();

      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('displays formatted price', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProduct));
      await tester.pump();

      expect(find.text('\$99.99'), findsOneWidget);
    });

    testWidgets('displays category chip when category exists', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProduct));
      await tester.pump();

      expect(find.text('Electronics'), findsOneWidget);
    });

    testWidgets('displays stock quantity when in stock', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProduct));
      await tester.pump();

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('displays 0 when out of stock', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(outOfStockProduct));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('displays "OUT OF STOCK" overlay when stock is 0', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(outOfStockProduct));
      await tester.pumpAndSettle();

      expect(find.text('OUT OF STOCK'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        testProduct,
        onTap: () => tapped = true,
      ));
      await tester.pump();

      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('shows edit button when onEdit is provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        testProduct,
        onEdit: () {},
      ));
      await tester.pump();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('hides edit button when onEdit is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProduct));
      await tester.pump();

      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('calls onEdit when edit button is tapped', (tester) async {
      var edited = false;
      await tester.pumpWidget(createWidgetUnderTest(
        testProduct,
        onEdit: () => edited = true,
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(edited, true);
    });

    testWidgets('shows placeholder when imageUrl is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(noImageProduct));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });

    testWidgets('handles long product names with overflow', (tester) async {
      const longNameProduct = Product(
        id: 4,
        name: 'This is a very long product name that should overflow',
        price: 19.99,
      );

      await tester.pumpWidget(createWidgetUnderTest(longNameProduct));
      await tester.pumpAndSettle();

      expect(find.textContaining('This is a very long'), findsOneWidget);
    });

    testWidgets('does not show OUT OF STOCK overlay when in stock', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(testProduct));
      await tester.pump();

      expect(find.text('OUT OF STOCK'), findsNothing);
    });

    testWidgets('displays category Furniture correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(outOfStockProduct));
      await tester.pumpAndSettle();

      expect(find.text('Furniture'), findsOneWidget);
    });
  });
}