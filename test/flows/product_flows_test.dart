import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/error/failures.dart';
import 'package:titan_flutter/features/products/presentation/screens/products_list_screen.dart';

import '../helpers/test_helpers.dart';
import '../robots/product_detail_robot.dart';
import '../robots/product_form_robot.dart';
import '../robots/product_list_robot.dart';

void main() {
  late MockGetProducts mockGetProducts;
  late MockGetProduct mockGetProduct;
  late MockCreateProduct mockCreateProduct;
  late MockUpdateProduct mockUpdateProduct;
  late MockDeleteProduct mockDeleteProduct;

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetProduct = MockGetProduct();
    mockCreateProduct = MockCreateProduct();
    mockUpdateProduct = MockUpdateProduct();
    mockDeleteProduct = MockDeleteProduct();

    setupTestDependencies(
      mockGetProducts: mockGetProducts,
      mockGetProduct: mockGetProduct,
      mockCreateProduct: mockCreateProduct,
      mockUpdateProduct: mockUpdateProduct,
      mockDeleteProduct: mockDeleteProduct,
    );
  });

  tearDown(() => tearDownTestDependencies());

  group('Product List Flows', () {
    testWidgets('1. Load products successfully', (tester) async {
      // Arrange
      final products = createTestProducts(2);
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: products)),
      );

      // Act
      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      final robot = ProductListRobot(tester);

      // Assert - shows loading first
      await robot.showsLoading();

      // Wait for data
      await tester.pumpAndSettle();

      // Assert - shows products (GridView only renders visible items)
      await robot.hasProducts();
      await robot.showsProductWithName('Product 1');
      await robot.showsProductWithName('Product 2');
    });

    testWidgets('2. Load products empty state', (tester) async {
      // Arrange
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [], total: 0)),
      );

      // Act
      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final robot = ProductListRobot(tester);

      // Assert
      await robot.showsEmptyState();
    });

    testWidgets('3. Load products error with retry', (tester) async {
      // Arrange - First call fails
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => const Left(NetworkFailure('Connection failed')),
      );

      // Act
      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final robot = ProductListRobot(tester);

      // Assert - shows error
      await robot.showsError();
      await robot.showsErrorMessage('Connection failed');

      // Arrange - Second call succeeds
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: createTestProducts(2))),
      );

      // Act - tap retry
      await robot.tapRetry();

      // Assert - shows products
      await robot.hasProducts();
    });

    testWidgets('4. Search products', (tester) async {
      // Arrange - Initial load
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: createTestProducts(2))),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final robot = ProductListRobot(tester);

      // Assert - initial products loaded
      await robot.hasProducts();

      // Arrange - Search returns filtered results
      final searchResult = [createTestProduct(id: 1, name: 'Laptop Pro')];
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: searchResult, total: 1)),
      );

      // Act - search
      await robot.enterSearchQuery('Laptop');
      await robot.submitSearch();

      // Assert - shows filtered results
      await robot.showsProducts(1);
      await robot.showsProductWithName('Laptop Pro');
    });

    testWidgets('5. Refresh products', (tester) async {
      // Arrange
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: createTestProducts(2))),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final robot = ProductListRobot(tester);
      await robot.hasProducts();
      await robot.showsProductWithName('Product 1');

      // Arrange - Refresh returns updated data with different name
      final updatedProducts = [createTestProduct(id: 1, name: 'Refreshed Product')];
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: updatedProducts)),
      );

      // Act
      await robot.tapRefresh();

      // Assert
      await robot.showsProductWithName('Refreshed Product');
    });
  });

  group('Product Creation Flows', () {
    testWidgets('6. Create product successfully', (tester) async {
      // Arrange
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: createTestProducts(2))),
      );

      final newProduct = createTestProduct(id: 99, name: 'New Gadget', price: 199.99);
      when(() => mockCreateProduct(any())).thenAnswer(
        (_) async => Right(newProduct),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final formRobot = ProductFormRobot(tester);

      // Act - Navigate to create
      await listRobot.tapAddProduct();

      // Assert - on create form
      await formRobot.isVisible();
      await formRobot.isCreateMode();

      // Act - Fill form and submit
      await formRobot.fillValidProductForm(
        name: 'New Gadget',
        price: '199.99',
        stock: '25',
        category: 'Electronics',
      );
      await formRobot.tapSubmit();

      // Assert - back to list with new product
      await tester.pumpAndSettle();
      await formRobot.isNotVisible();
      await listRobot.isVisible();
      await listRobot.showsProductWithName('New Gadget');
    });

    testWidgets('7. Create product validation error', (tester) async {
      // Arrange
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [])),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final formRobot = ProductFormRobot(tester);

      // Act - Navigate to create
      await listRobot.tapAddProduct();

      // Act - Submit empty form
      await formRobot.tapSubmit();

      // Assert - validation errors shown
      await formRobot.showsValidationError('Product name is required');
      await formRobot.showsValidationError('Price is required');

      // Act - Enter short name
      await formRobot.enterName('AB');
      await formRobot.tapSubmit();

      // Assert - name too short error
      await formRobot.showsValidationError('Name must be at least 3 characters');
    });
  });

  group('Product Detail Flows', () {
    testWidgets('8. View product detail', (tester) async {
      // Arrange
      final product = createTestProduct(
        id: 1,
        name: 'Premium Headphones',
        price: 299.99,
        description: 'High quality audio',
        category: 'Electronics',
      );
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [product])),
      );
      when(() => mockGetProduct(1)).thenAnswer((_) async => Right(product));

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final detailRobot = ProductDetailRobot(tester);

      // Act - Tap product
      await listRobot.tapProduct(0);
      await tester.pumpAndSettle();

      // Assert - detail screen shown
      await detailRobot.isVisible();
      await detailRobot.showsProductName('Premium Headphones');
      await detailRobot.showsProductCategory('Electronics');
    });

    testWidgets('9. Delete product successfully', (tester) async {
      // Arrange
      final product = createTestProduct(id: 1, name: 'Product to Delete');
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [product])),
      );
      when(() => mockGetProduct(1)).thenAnswer((_) async => Right(product));
      when(() => mockDeleteProduct(1)).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final detailRobot = ProductDetailRobot(tester);

      // Navigate to detail
      await listRobot.tapProduct(0);
      await tester.pumpAndSettle();
      await detailRobot.isVisible();

      // Act - Delete
      await detailRobot.tapDeleteButton();
      await detailRobot.showsDeleteDialog();
      await detailRobot.confirmDelete();

      // Assert - back to list, product removed
      await tester.pumpAndSettle();
      await listRobot.isVisible();
      await listRobot.doesNotShowProductWithName('Product to Delete');
    });
  });

  group('Product Edit Flows', () {
    testWidgets('10. Edit product successfully', (tester) async {
      // Arrange
      final product = createTestProduct(
        id: 1,
        name: 'Original Name',
        price: 50.00,
      );
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [product])),
      );
      when(() => mockGetProduct(1)).thenAnswer((_) async => Right(product));

      final updatedProduct = createTestProduct(
        id: 1,
        name: 'Updated Name',
        price: 75.00,
      );
      when(() => mockUpdateProduct(any())).thenAnswer(
        (_) async => Right(updatedProduct),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final detailRobot = ProductDetailRobot(tester);
      final formRobot = ProductFormRobot(tester);

      // Navigate to detail then edit
      await listRobot.tapProduct(0);
      await tester.pumpAndSettle();
      await detailRobot.tapEditButton();

      // Assert - edit form shown with data
      await formRobot.isVisible();
      await formRobot.isEditMode();

      // Act - Update and submit
      await formRobot.enterName('Updated Name');
      await formRobot.enterPrice('75.00');
      await formRobot.tapSubmit();

      // Assert - back to detail with updated data
      await tester.pumpAndSettle();
      await detailRobot.isVisible();
      await detailRobot.showsProductName('Updated Name');
    });

    testWidgets('11. Edit product from list', (tester) async {
      // Arrange
      final product = createTestProduct(id: 1, name: 'Edit Me');
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [product])),
      );

      final updatedProduct = createTestProduct(id: 1, name: 'Edited Product');
      when(() => mockUpdateProduct(any())).thenAnswer(
        (_) async => Right(updatedProduct),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final formRobot = ProductFormRobot(tester);

      // Act - Edit from list
      await listRobot.tapEditButton(0);

      // Assert - edit form
      await formRobot.isVisible();
      await formRobot.isEditMode();

      // Update
      await formRobot.enterName('Edited Product');
      await formRobot.tapSubmit();

      // Assert - back to list with updated product
      await tester.pumpAndSettle();
      await listRobot.isVisible();
      await listRobot.showsProductWithName('Edited Product');
    });
  });

  group('Error Handling Flows', () {
    testWidgets('12. API error on create shows error message', (tester) async {
      // Arrange
      when(() => mockGetProducts(any())).thenAnswer(
        (_) async => Right(createTestProductsResult(products: [])),
      );
      when(() => mockCreateProduct(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Server error occurred')),
      );

      await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
      await tester.pumpAndSettle();

      final listRobot = ProductListRobot(tester);
      final formRobot = ProductFormRobot(tester);

      // Navigate to create
      await listRobot.tapAddProduct();

      // Fill and submit
      await formRobot.fillValidProductForm(name: 'Test Product', price: '50.00');
      await formRobot.tapSubmit();

      // Assert - error shown
      await tester.pumpAndSettle();
      await formRobot.showsError('Server error occurred');
      await formRobot.isVisible(); // Still on form
    });
  });
}
