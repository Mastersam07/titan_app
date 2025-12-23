import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/features/products/presentation/screens/products_list_screen.dart';
import 'package:titan_flutter/features/products/presentation/widgets/error_view.dart';
import 'package:titan_flutter/features/products/presentation/widgets/product_card.dart';
import 'package:titan_flutter/features/products/presentation/widgets/shimmer_loading.dart';

class ProductListRobot {
  ProductListRobot(this.tester);

  final WidgetTester tester;

  // Finders
  Finder get screen => find.byType(ProductsListScreen);
  Finder get appBarTitle => find.text('Titan Products');
  Finder get searchField => find.byType(TextField);
  Finder get refreshButton => find.byIcon(Icons.refresh);
  Finder get addProductFab => find.byType(FloatingActionButton);
  Finder get productGrid => find.byType(GridView);
  Finder get shimmerLoading => find.byType(ProductsGridShimmer);
  Finder get emptyView => find.byType(EmptyView);
  Finder get errorView => find.byType(ErrorView);
  Finder get productCards => find.byType(ProductCard);
  Finder get retryButton => find.text('Try Again');

  Finder productCardAt(int index) => find.byType(ProductCard).at(index);
  Finder productWithName(String name) => find.text(name);
  Finder editButtonFor(int index) => find.descendant(
        of: productCardAt(index),
        matching: find.byIcon(Icons.edit),
      );

  // Assertions
  Future<void> isVisible() async => expect(screen, findsOneWidget);

  Future<void> showsLoading() async => expect(shimmerLoading, findsOneWidget);

  Future<void> showsProducts(int count) async => expect(productCards, findsNWidgets(count));

  Future<void> showsAtLeastProducts(int count) async => expect(productCards, findsAtLeast(count));

  Future<void> hasProducts() async => expect(productCards, findsWidgets);

  Future<void> showsEmptyState() async => expect(emptyView, findsOneWidget);

  Future<void> showsError() async => expect(errorView, findsOneWidget);

  Future<void> showsErrorMessage(String message) async => expect(find.text(message), findsOneWidget);

  Future<void> showsProductWithName(String name) async => expect(productWithName(name), findsOneWidget);

  Future<void> doesNotShowProductWithName(String name) async => expect(productWithName(name), findsNothing);

  Future<void> showsSearchField() async => expect(searchField, findsOneWidget);

  // Actions
  Future<void> tapAddProduct() async {
    await tester.tap(addProductFab);
    await tester.pumpAndSettle();
  }

  Future<void> tapProduct(int index) async {
    await tester.tap(productCardAt(index));
    await tester.pumpAndSettle();
  }

  Future<void> tapProductByName(String name) async {
    final card = find.ancestor(of: find.text(name), matching: find.byType(ProductCard));
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  Future<void> tapEditButton(int index) async {
    await tester.tap(editButtonFor(index));
    await tester.pumpAndSettle();
  }

  Future<void> tapRefresh() async {
    await tester.tap(refreshButton);
    await tester.pumpAndSettle();
  }

  Future<void> tapRetry() async {
    await tester.tap(retryButton);
    await tester.pumpAndSettle();
  }

  Future<void> enterSearchQuery(String query) async {
    await tester.enterText(searchField, query);
    await tester.pumpAndSettle();
  }

  Future<void> submitSearch() async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Future<void> pullToRefresh() async {
    await tester.drag(productGrid, const Offset(0, 300));
    await tester.pumpAndSettle();
  }

  Future<void> scrollToBottom() async {
    await tester.drag(productGrid, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
}
