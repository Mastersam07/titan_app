import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/error/failures.dart';
import 'package:titan_flutter/features/products/domain/entities/product.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_create/product_create_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_create/product_create_state.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProductCreateCubit cubit;
  late MockCreateProduct mockCreateProduct;

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockCreateProduct = MockCreateProduct();
    cubit = ProductCreateCubit(createProduct: mockCreateProduct);
  });

  tearDown(() => cubit.close());

  group('ProductCreateCubit', () {
    test('initial state is ProductCreateInitial', () {
      expect(cubit.state, const ProductCreateInitial());
    });

    group('create', () {
      final createdProduct = createTestProduct(
        id: 99,
        name: 'New Product',
        price: 49.99,
        stockQuantity: 10,
        category: 'Electronics',
      );

      blocTest<ProductCreateCubit, ProductCreateState>(
        'emits [Submitting, Success] when successful',
        build: () {
          when(() => mockCreateProduct(any())).thenAnswer((_) async => Right(createdProduct));
          return cubit;
        },
        act: (cubit) => cubit.create(
          name: 'New Product',
          price: 49.99,
          stockQuantity: 10,
          category: 'Electronics',
        ),
        expect: () => [
          const ProductCreateSubmitting(),
          ProductCreateSuccess(product: createdProduct),
        ],
        verify: (_) {
          final captured = verify(() => mockCreateProduct(captureAny())).captured;
          final product = captured.first as Product;
          expect(product.name, 'New Product');
          expect(product.price, 49.99);
          expect(product.stockQuantity, 10);
          expect(product.category, 'Electronics');
        },
      );

      blocTest<ProductCreateCubit, ProductCreateState>(
        'emits [Submitting, Error] when fails',
        build: () {
          when(() => mockCreateProduct(any())).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return cubit;
        },
        act: (cubit) => cubit.create(
          name: 'New Product',
          price: 49.99,
          stockQuantity: 10,
        ),
        expect: () => [
          const ProductCreateSubmitting(),
          const ProductCreateError(message: 'Server error'),
        ],
      );

      blocTest<ProductCreateCubit, ProductCreateState>(
        'emits [Submitting, Error] on network failure',
        build: () {
          when(() => mockCreateProduct(any())).thenAnswer((_) async => const Left(NetworkFailure('No internet')));
          return cubit;
        },
        act: (cubit) => cubit.create(
          name: 'New Product',
          price: 49.99,
          stockQuantity: 10,
        ),
        expect: () => [
          const ProductCreateSubmitting(),
          const ProductCreateError(message: 'No internet'),
        ],
      );

      blocTest<ProductCreateCubit, ProductCreateState>(
        'passes optional fields correctly',
        build: () {
          when(() => mockCreateProduct(any())).thenAnswer((_) async => Right(createdProduct));
          return cubit;
        },
        act: (cubit) => cubit.create(
          name: 'New Product',
          description: 'A description',
          price: 49.99,
          imageUrl: 'https://example.com/image.jpg',
          stockQuantity: 10,
          category: 'Electronics',
        ),
        verify: (_) {
          final captured = verify(() => mockCreateProduct(captureAny())).captured;
          final product = captured.first as Product;
          expect(product.description, 'A description');
          expect(product.imageUrl, 'https://example.com/image.jpg');
        },
      );

      blocTest<ProductCreateCubit, ProductCreateState>(
        'creates product with id 0 (server assigns real id)',
        build: () {
          when(() => mockCreateProduct(any())).thenAnswer((_) async => Right(createdProduct));
          return cubit;
        },
        act: (cubit) => cubit.create(
          name: 'New Product',
          price: 49.99,
          stockQuantity: 10,
        ),
        verify: (_) {
          final captured = verify(() => mockCreateProduct(captureAny())).captured;
          final product = captured.first as Product;
          expect(product.id, 0);
        },
      );
    });

    group('reset', () {
      blocTest<ProductCreateCubit, ProductCreateState>(
        'emits [Initial] from Success state',
        build: () => cubit,
        seed: () => ProductCreateSuccess(product: createTestProduct()),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const ProductCreateInitial(),
        ],
      );

      blocTest<ProductCreateCubit, ProductCreateState>(
        'emits [Initial] from Error state',
        build: () => cubit,
        seed: () => const ProductCreateError(message: 'Error'),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const ProductCreateInitial(),
        ],
      );
    });
  });
}
