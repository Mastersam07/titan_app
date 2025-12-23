import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/features/products/domain/entities/product.dart';
import 'package:titan_flutter/features/products/domain/repositories/product_repository.dart';
import 'package:titan_flutter/features/products/domain/usecases/create_product.dart';
import 'package:titan_flutter/features/products/domain/usecases/delete_product.dart';
import 'package:titan_flutter/features/products/domain/usecases/get_product.dart';
import 'package:titan_flutter/features/products/domain/usecases/get_products.dart';
import 'package:titan_flutter/features/products/domain/usecases/update_product.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_create/product_create_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_detail/product_detail_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_edit/product_edit_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_list/product_list_cubit.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockGetProducts extends Mock implements GetProducts {}

class MockGetProduct extends Mock implements GetProduct {}

class MockCreateProduct extends Mock implements CreateProduct {}

class MockUpdateProduct extends Mock implements UpdateProduct {}

class MockDeleteProduct extends Mock implements DeleteProduct {}

class FakeProduct extends Fake implements Product {}

class FakeGetProductsParams extends Fake implements GetProductsParams {}

class FakeUpdateProductParams extends Fake implements UpdateProductParams {}

Product createTestProduct({
  int id = 1,
  String name = 'Test Product',
  String? description = 'Test Description',
  double price = 99.99,
  String? imageUrl,
  int stockQuantity = 10,
  String? category = 'Electronics',
  DateTime? createdAt,
  DateTime? updatedAt,
}) =>
    Product(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      stockQuantity: stockQuantity,
      category: category,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

List<Product> createTestProducts(int count) => List.generate(
      count,
      (index) => createTestProduct(
        id: index + 1,
        name: 'Product ${index + 1}',
        price: (index + 1) * 10.0,
        stockQuantity: index * 5,
      ),
    );

ProductsResult createTestProductsResult({
  List<Product>? products,
  int total = 10,
  int limit = 20,
  int offset = 0,
}) =>
    ProductsResult(
      products: products ?? createTestProducts(total > 5 ? 5 : total),
      meta: PaginationMeta(total: total, limit: limit, offset: offset),
    );

void registerFallbackValues() {
  registerFallbackValue(FakeProduct());
  registerFallbackValue(FakeGetProductsParams());
  registerFallbackValue(FakeUpdateProductParams());
}

final di = GetIt.instance;

void setupTestDependencies({
  MockGetProducts? mockGetProducts,
  MockGetProduct? mockGetProduct,
  MockCreateProduct? mockCreateProduct,
  MockUpdateProduct? mockUpdateProduct,
  MockDeleteProduct? mockDeleteProduct,
}) {
  di.reset();

  final getProducts = mockGetProducts ?? MockGetProducts();
  final getProduct = mockGetProduct ?? MockGetProduct();
  final createProduct = mockCreateProduct ?? MockCreateProduct();
  final updateProduct = mockUpdateProduct ?? MockUpdateProduct();
  final deleteProduct = mockDeleteProduct ?? MockDeleteProduct();

  di.registerLazySingleton<GetProducts>(() => getProducts);
  di.registerLazySingleton<GetProduct>(() => getProduct);
  di.registerLazySingleton<CreateProduct>(() => createProduct);
  di.registerLazySingleton<UpdateProduct>(() => updateProduct);
  di.registerLazySingleton<DeleteProduct>(() => deleteProduct);

  di.registerFactory<ProductListCubit>(() => ProductListCubit(getProducts: di()));

  di.registerFactory<ProductDetailCubit>(() => ProductDetailCubit(getProduct: di(), deleteProduct: di()));

  di.registerFactory<ProductCreateCubit>(() => ProductCreateCubit(createProduct: di()));

  di.registerFactory<ProductEditCubit>(() => ProductEditCubit(getProduct: di(), updateProduct: di()));
}

void tearDownTestDependencies() => di.reset();

Widget createTestApp({required Widget child}) => MaterialApp(home: child);
