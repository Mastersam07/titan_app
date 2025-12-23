import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/failures.dart';
import 'package:titan_flutter/data/providers/api_provider.dart';
import 'package:titan_flutter/data/repositories/product_repository.dart';
import 'package:titan_flutter/models/api_response.dart';
import 'package:titan_flutter/models/product.dart';

class MockApiProvider extends Mock implements ApiProvider {}

void main() {
  late MockApiProvider mockApiProvider;
  late ProductRepository repository;

  final testProducts = [
    const Product(id: 1, name: 'Product 1', price: 99.99),
    const Product(id: 2, name: 'Product 2', price: 149.99),
  ];

  final testResponse = ProductsResponse(
    success: true,
    products: testProducts,
    meta: const PaginationMeta(total: 2, limit: 20, offset: 0),
  );

  final testProductResponse = ProductResponse(
    success: true,
    product: testProducts[0],
    message: 'Success',
  );

  setUp(() {
    mockApiProvider = MockApiProvider();
    repository = ProductRepository(apiProvider: mockApiProvider);
  });

  group('ProductRepository', () {
    group('getProducts', () {
      test('returns Right with ProductsResponse on success', () async {
        when(() => mockApiProvider.getProducts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              category: any(named: 'category'),
              search: any(named: 'search'),
            )).thenAnswer((_) async => testResponse);

        final result = await repository.getProducts();

        expect(result, isA<Right<Failure, ProductsResponse>>());
        result.fold(
          (l) => fail('Should not return Left'),
          (r) {
            expect(r.products.length, 2);
            expect(r.success, true);
          },
        );
      });

      test('returns Left with Failure on network error', () async {
        when(() => mockApiProvider.getProducts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              category: any(named: 'category'),
              search: any(named: 'search'),
            )).thenThrow(const NetworkFailure('No connection'));

        final result = await repository.getProducts();

        expect(result, isA<Left<Failure, ProductsResponse>>());
        result.fold(
          (l) => expect(l.message, 'No connection'),
          (r) => fail('Should not return Right'),
        );
      });

      test('returns Left with ServerFailure on unexpected error', () async {
        when(() => mockApiProvider.getProducts(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
              category: any(named: 'category'),
              search: any(named: 'search'),
            )).thenThrow(Exception('Unexpected error'));

        final result = await repository.getProducts();

        expect(result, isA<Left<Failure, ProductsResponse>>());
        result.fold(
          (l) => expect(l, isA<ServerFailure>()),
          (r) => fail('Should not return Right'),
        );
      });

      test('passes parameters correctly', () async {
        when(() => mockApiProvider.getProducts(
              limit: 10,
              offset: 20,
              category: 'Electronics',
              search: 'phone',
            )).thenAnswer((_) async => testResponse);

        await repository.getProducts(
          limit: 10,
          offset: 20,
          category: 'Electronics',
          search: 'phone',
        );

        verify(() => mockApiProvider.getProducts(
              limit: 10,
              offset: 20,
              category: 'Electronics',
              search: 'phone',
            )).called(1);
      });
    });

    group('getProduct', () {
      test('returns Right with Product on success', () async {
        when(() => mockApiProvider.getProduct(1)).thenAnswer((_) async => testProductResponse);

        final result = await repository.getProduct(1);

        expect(result, isA<Right<Failure, Product>>());
        result.fold(
          (l) => fail('Should not return Left'),
          (r) => expect(r.id, 1),
        );
      });

      test('returns Left with NotFoundFailure on 404', () async {
        when(() => mockApiProvider.getProduct(999)).thenThrow(const NotFoundFailure('Product not found'));

        final result = await repository.getProduct(999);

        expect(result, isA<Left<Failure, Product>>());
        result.fold(
          (l) => expect(l, isA<NotFoundFailure>()),
          (r) => fail('Should not return Right'),
        );
      });
    });

    group('createProduct', () {
      const newProduct = Product(
        id: 0,
        name: 'New Product',
        price: 199.99,
        description: 'A new product',
      );

      test('returns Right with created Product on success', () async {
        final createdResponse = ProductResponse(
          success: true,
          product: newProduct.copyWith(id: 3),
          message: 'Created',
        );

        when(() => mockApiProvider.createProduct(newProduct)).thenAnswer((_) async => createdResponse);

        final result = await repository.createProduct(newProduct);

        expect(result, isA<Right<Failure, Product>>());
        result.fold(
          (l) => fail('Should not return Left'),
          (r) => expect(r.id, 3),
        );
      });

      test('returns Left with ValidationFailure on 422', () async {
        when(() => mockApiProvider.createProduct(newProduct)).thenThrow(const ValidationFailure('Name is required'));

        final result = await repository.createProduct(newProduct);

        expect(result, isA<Left<Failure, Product>>());
        result.fold(
          (l) {
            expect(l, isA<ValidationFailure>());
            expect(l.message, 'Name is required');
          },
          (r) => fail('Should not return Right'),
        );
      });
    });

    group('updateProduct', () {
      test('returns Right with updated Product on success', () async {
        final updatedProduct = testProducts[0].copyWith(name: 'Updated Name');
        final updateResponse = ProductResponse(
          success: true,
          product: updatedProduct,
        );

        when(() => mockApiProvider.updateProduct(1, {'name': 'Updated Name'})).thenAnswer((_) async => updateResponse);

        final result = await repository.updateProduct(1, {'name': 'Updated Name'});

        expect(result, isA<Right<Failure, Product>>());
        result.fold(
          (l) => fail('Should not return Left'),
          (r) => expect(r.name, 'Updated Name'),
        );
      });
    });

    group('deleteProduct', () {
      test('returns Right with true on success', () async {
        when(() => mockApiProvider.deleteProduct(1)).thenAnswer((_) async => true);

        final result = await repository.deleteProduct(1);

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (l) => fail('Should not return Left'),
          (r) => expect(r, true),
        );
      });

      test('returns Left with NotFoundFailure when product not found', () async {
        when(() => mockApiProvider.deleteProduct(999)).thenThrow(const NotFoundFailure('Product not found'));

        final result = await repository.deleteProduct(999);

        expect(result, isA<Left<Failure, bool>>());
        result.fold(
          (l) => expect(l, isA<NotFoundFailure>()),
          (r) => fail('Should not return Right'),
        );
      });
    });

    group('checkHealth', () {
      test('returns Right with true when healthy', () async {
        when(() => mockApiProvider.checkHealth()).thenAnswer((_) async => true);

        final result = await repository.checkHealth();

        expect(result, isA<Right<Failure, bool>>());
        result.fold(
          (l) => fail('Should not return Left'),
          (r) => expect(r, true),
        );
      });

      test('returns Left with NetworkFailure when unhealthy', () async {
        when(() => mockApiProvider.checkHealth()).thenThrow(const NetworkFailure('Cannot connect'));

        final result = await repository.checkHealth();

        expect(result, isA<Left<Failure, bool>>());
      });
    });
  });
}
