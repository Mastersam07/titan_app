import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/error/failures.dart';
import 'package:titan_flutter/features/products/domain/usecases/update_product.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_edit/product_edit_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_edit/product_edit_state.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProductEditCubit cubit;
  late MockGetProduct mockGetProduct;
  late MockUpdateProduct mockUpdateProduct;

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetProduct = MockGetProduct();
    mockUpdateProduct = MockUpdateProduct();
    cubit = ProductEditCubit(
      getProduct: mockGetProduct,
      updateProduct: mockUpdateProduct,
    );
  });

  tearDown(() => cubit.close());

  group('ProductEditCubit', () {
    test('initial state is ProductEditInitial', () {
      expect(cubit.state, const ProductEditInitial());
    });

    group('loadProduct', () {
      final product = createTestProduct(id: 1, name: 'Test Product');

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Loading, Loaded] when successful',
        build: () {
          when(() => mockGetProduct(1)).thenAnswer((_) async => Right(product));
          return cubit;
        },
        act: (cubit) => cubit.loadProduct(1),
        expect: () => [
          const ProductEditLoading(),
          ProductEditLoaded(product: product),
        ],
        verify: (_) {
          verify(() => mockGetProduct(1)).called(1);
        },
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockGetProduct(1)).thenAnswer((_) async => const Left(NotFoundFailure('Product not found')));
          return cubit;
        },
        act: (cubit) => cubit.loadProduct(1),
        expect: () => [
          const ProductEditLoading(),
          const ProductEditError(message: 'Product not found'),
        ],
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Loading, Error] on network failure',
        build: () {
          when(() => mockGetProduct(1)).thenAnswer((_) async => const Left(NetworkFailure('No internet')));
          return cubit;
        },
        act: (cubit) => cubit.loadProduct(1),
        expect: () => [
          const ProductEditLoading(),
          const ProductEditError(message: 'No internet'),
        ],
      );
    });

    group('setProduct', () {
      final product = createTestProduct(id: 1, name: 'Direct Product');

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Loaded] with provided product',
        build: () => cubit,
        act: (cubit) => cubit.setProduct(product),
        expect: () => [
          ProductEditLoaded(product: product),
        ],
      );
    });

    group('update', () {
      final originalProduct = createTestProduct(
        id: 1,
        name: 'Original Name',
        price: 50.00,
      );
      final updatedProduct = createTestProduct(
        id: 1,
        name: 'Updated Name',
        price: 75.00,
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Submitting, Success] when successful',
        build: () {
          when(() => mockUpdateProduct(any())).thenAnswer((_) async => Right(updatedProduct));
          return cubit;
        },
        seed: () => ProductEditLoaded(product: originalProduct),
        act: (cubit) => cubit.update(
          id: 1,
          name: 'Updated Name',
          price: 75.00,
          stockQuantity: 100,
        ),
        expect: () => [
          ProductEditSubmitting(product: originalProduct),
          ProductEditSuccess(product: updatedProduct),
        ],
        verify: (_) {
          final captured = verify(() => mockUpdateProduct(captureAny())).captured;
          final params = captured.first as UpdateProductParams;
          expect(params.id, 1);
          expect(params.data['name'], 'Updated Name');
          expect(params.data['price'], 75.00);
          expect(params.data['stock_quantity'], 100);
        },
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Submitting, Error] when fails',
        build: () {
          when(() => mockUpdateProduct(any())).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return cubit;
        },
        seed: () => ProductEditLoaded(product: originalProduct),
        act: (cubit) => cubit.update(
          id: 1,
          name: 'Updated Name',
          price: 75.00,
          stockQuantity: 100,
        ),
        expect: () => [
          ProductEditSubmitting(product: originalProduct),
          ProductEditError(message: 'Server error', product: originalProduct),
        ],
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Submitting, Error] on network failure',
        build: () {
          when(() => mockUpdateProduct(any())).thenAnswer((_) async => const Left(NetworkFailure('No internet')));
          return cubit;
        },
        seed: () => ProductEditLoaded(product: originalProduct),
        act: (cubit) => cubit.update(
          id: 1,
          name: 'Updated Name',
          price: 75.00,
          stockQuantity: 100,
        ),
        expect: () => [
          ProductEditSubmitting(product: originalProduct),
          ProductEditError(message: 'No internet', product: originalProduct),
        ],
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'passes optional fields correctly',
        build: () {
          when(() => mockUpdateProduct(any())).thenAnswer((_) async => Right(updatedProduct));
          return cubit;
        },
        seed: () => ProductEditLoaded(product: originalProduct),
        act: (cubit) => cubit.update(
          id: 1,
          name: 'Updated Name',
          description: 'New description',
          price: 75.00,
          imageUrl: 'https://example.com/image.jpg',
          stockQuantity: 100,
          category: 'Electronics',
        ),
        verify: (_) {
          final captured = verify(() => mockUpdateProduct(captureAny())).captured;
          final params = captured.first as UpdateProductParams;
          expect(params.data['description'], 'New description');
          expect(params.data['image_url'], 'https://example.com/image.jpg');
          expect(params.data['category'], 'Electronics');
        },
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'can update from Error state with product',
        build: () {
          when(() => mockUpdateProduct(any())).thenAnswer((_) async => Right(updatedProduct));
          return cubit;
        },
        seed: () => ProductEditError(message: 'Previous error', product: originalProduct),
        act: (cubit) => cubit.update(
          id: 1,
          name: 'Updated Name',
          price: 75.00,
          stockQuantity: 100,
        ),
        expect: () => [
          ProductEditSubmitting(product: originalProduct),
          ProductEditSuccess(product: updatedProduct),
        ],
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'does not emit Submitting when no product in state',
        build: () {
          when(() => mockUpdateProduct(any())).thenAnswer((_) async => Right(updatedProduct));
          return cubit;
        },
        act: (cubit) => cubit.update(
          id: 1,
          name: 'Updated Name',
          price: 75.00,
          stockQuantity: 100,
        ),
        expect: () => [
          ProductEditSuccess(product: updatedProduct),
        ],
      );
    });

    group('reset', () {
      final product = createTestProduct();

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Initial] from Loaded state',
        build: () => cubit,
        seed: () => ProductEditLoaded(product: product),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const ProductEditInitial(),
        ],
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Initial] from Success state',
        build: () => cubit,
        seed: () => ProductEditSuccess(product: product),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const ProductEditInitial(),
        ],
      );

      blocTest<ProductEditCubit, ProductEditState>(
        'emits [Initial] from Error state',
        build: () => cubit,
        seed: () => const ProductEditError(message: 'Error'),
        act: (cubit) => cubit.reset(),
        expect: () => [
          const ProductEditInitial(),
        ],
      );
    });
  });
}
