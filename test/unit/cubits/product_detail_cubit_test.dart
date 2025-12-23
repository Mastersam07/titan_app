import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/error/failures.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_detail/product_detail_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_detail/product_detail_state.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProductDetailCubit cubit;
  late MockGetProduct mockGetProduct;
  late MockDeleteProduct mockDeleteProduct;

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetProduct = MockGetProduct();
    mockDeleteProduct = MockDeleteProduct();
    cubit = ProductDetailCubit(
      getProduct: mockGetProduct,
      deleteProduct: mockDeleteProduct,
    );
  });

  tearDown(() => cubit.close());

  group('ProductDetailCubit', () {
    test('initial state is ProductDetailInitial', () {
      expect(cubit.state, const ProductDetailInitial());
    });

    group('loadProduct', () {
      final product = createTestProduct(id: 1, name: 'Test Product');

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Loading, Loaded] when successful',
        build: () {
          when(() => mockGetProduct(1)).thenAnswer((_) async => Right(product));
          return cubit;
        },
        act: (cubit) => cubit.loadProduct(1),
        expect: () => [
          const ProductDetailLoading(),
          ProductDetailLoaded(product: product),
        ],
        verify: (_) {
          verify(() => mockGetProduct(1)).called(1);
        },
      );

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockGetProduct(1)).thenAnswer((_) async => const Left(NotFoundFailure('Product not found')));
          return cubit;
        },
        act: (cubit) => cubit.loadProduct(1),
        expect: () => [
          const ProductDetailLoading(),
          const ProductDetailError(message: 'Product not found'),
        ],
      );

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Loading, Error] on network failure',
        build: () {
          when(() => mockGetProduct(1)).thenAnswer((_) async => const Left(NetworkFailure('No internet')));
          return cubit;
        },
        act: (cubit) => cubit.loadProduct(1),
        expect: () => [
          const ProductDetailLoading(),
          const ProductDetailError(message: 'No internet'),
        ],
      );
    });

    group('setProduct', () {
      final product = createTestProduct(id: 1, name: 'Direct Product');

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Loaded] with provided product',
        build: () => cubit,
        act: (cubit) => cubit.setProduct(product),
        expect: () => [
          ProductDetailLoaded(product: product),
        ],
      );
    });

    group('delete', () {
      final product = createTestProduct(id: 1, name: 'Product to Delete');

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Deleting, Deleted] when successful',
        build: () {
          when(() => mockDeleteProduct(1)).thenAnswer((_) async => const Right(true));
          return cubit;
        },
        seed: () => ProductDetailLoaded(product: product),
        act: (cubit) => cubit.delete(),
        expect: () => [
          ProductDetailDeleting(product: product),
          const ProductDetailDeleted(),
        ],
        verify: (_) {
          verify(() => mockDeleteProduct(1)).called(1);
        },
      );

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Deleting, Error] when delete returns false',
        build: () {
          when(() => mockDeleteProduct(1)).thenAnswer((_) async => const Right(false));
          return cubit;
        },
        seed: () => ProductDetailLoaded(product: product),
        act: (cubit) => cubit.delete(),
        expect: () => [
          ProductDetailDeleting(product: product),
          ProductDetailError(message: 'Failed to delete product', product: product),
        ],
      );

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Deleting, Error] when delete fails',
        build: () {
          when(() => mockDeleteProduct(1)).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return cubit;
        },
        seed: () => ProductDetailLoaded(product: product),
        act: (cubit) => cubit.delete(),
        expect: () => [
          ProductDetailDeleting(product: product),
          ProductDetailError(message: 'Server error', product: product),
        ],
      );

      blocTest<ProductDetailCubit, ProductDetailState>(
        'does nothing when not in Loaded state',
        build: () => cubit,
        seed: () => const ProductDetailLoading(),
        act: (cubit) => cubit.delete(),
        expect: () => [],
      );

      test('returns false when not in Loaded state', () async {
        final result = await cubit.delete();
        expect(result, false);
      });

      test('returns true when delete succeeds', () async {
        when(() => mockDeleteProduct(1)).thenAnswer((_) async => const Right(true));
        cubit.setProduct(product);
        final result = await cubit.delete();
        expect(result, true);
      });

      test('returns false when delete fails', () async {
        when(() => mockDeleteProduct(1)).thenAnswer((_) async => const Left(ServerFailure('Error')));
        cubit.setProduct(product);
        final result = await cubit.delete();
        expect(result, false);
      });
    });

    group('updateProduct', () {
      final originalProduct = createTestProduct(id: 1, name: 'Original');
      final updatedProduct = createTestProduct(id: 1, name: 'Updated');

      blocTest<ProductDetailCubit, ProductDetailState>(
        'emits [Loaded] with updated product',
        build: () => cubit,
        seed: () => ProductDetailLoaded(product: originalProduct),
        act: (cubit) => cubit.updateProduct(updatedProduct),
        expect: () => [
          ProductDetailLoaded(product: updatedProduct),
        ],
      );
    });
  });
}
