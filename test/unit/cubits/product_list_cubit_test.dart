import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/error/failures.dart';
import 'package:titan_flutter/features/products/domain/repositories/product_repository.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_list/product_list_cubit.dart';
import 'package:titan_flutter/features/products/presentation/cubits/product_list/product_list_state.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late ProductListCubit cubit;
  late MockGetProducts mockGetProducts;

  setUpAll(() => registerFallbackValues());

  setUp(() {
    mockGetProducts = MockGetProducts();
    cubit = ProductListCubit(getProducts: mockGetProducts);
  });

  tearDown(() => cubit.close());

  group('ProductListCubit', () {
    test('initial state is ProductListInitial', () {
      expect(cubit.state, const ProductListInitial());
    });

    group('fetchProducts', () {
      final products = createTestProducts(3);
      final productsResult = createTestProductsResult(products: products);

      blocTest<ProductListCubit, ProductListState>(
        'emits [Loading, Loaded] when successful',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer((_) async => Right(productsResult));
          return cubit;
        },
        act: (cubit) => cubit.fetchProducts(),
        expect: () => [
          const ProductListLoading(),
          ProductListLoaded(
            products: products,
            meta: productsResult.meta,
            searchQuery: null,
            categoryFilter: null,
          ),
        ],
        verify: (_) {
          verify(() => mockGetProducts(any())).called(1);
        },
      );

      blocTest<ProductListCubit, ProductListState>(
        'emits [Loading, Error] when fails',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer((_) async => const Left(NetworkFailure('No internet')));
          return cubit;
        },
        act: (cubit) => cubit.fetchProducts(),
        expect: () => [
          const ProductListLoading(),
          const ProductListError(message: 'No internet'),
        ],
      );

      blocTest<ProductListCubit, ProductListState>(
        'passes correct params with search query',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer((_) async => Right(productsResult));
          return cubit;
        },
        act: (cubit) => cubit.fetchProducts(search: 'laptop'),
        verify: (_) {
          final captured = verify(() => mockGetProducts(captureAny())).captured;
          final params = captured.first as GetProductsParams;
          expect(params.search, 'laptop');
        },
      );

      blocTest<ProductListCubit, ProductListState>(
        'passes correct params with category filter',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer((_) async => Right(productsResult));
          return cubit;
        },
        act: (cubit) => cubit.fetchProducts(category: 'Electronics'),
        verify: (_) {
          final captured = verify(() => mockGetProducts(captureAny())).captured;
          final params = captured.first as GetProductsParams;
          expect(params.category, 'Electronics');
        },
      );
    });

    group('loadMore', () {
      final initialProducts = createTestProducts(2);
      final moreProducts = [
        createTestProduct(id: 3, name: 'Product 3'),
        createTestProduct(id: 4, name: 'Product 4'),
      ];

      blocTest<ProductListCubit, ProductListState>(
        'emits [Loading(isLoadingMore), Loaded] with combined products',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer(
            (_) async => Right(createTestProductsResult(
              products: moreProducts,
              total: 10,
              limit: 2,
              offset: 2,
            )),
          );
          return cubit;
        },
        seed: () => ProductListLoaded(
          products: initialProducts,
          meta: const PaginationMeta(total: 10, limit: 2, offset: 0),
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [
          ProductListLoading(isLoadingMore: true, existingProducts: initialProducts),
          ProductListLoaded(
            products: [...initialProducts, ...moreProducts],
            meta: const PaginationMeta(total: 10, limit: 2, offset: 2),
          ),
        ],
      );

      blocTest<ProductListCubit, ProductListState>(
        'does nothing when not in Loaded state',
        build: () => cubit,
        seed: () => const ProductListLoading(),
        act: (cubit) => cubit.loadMore(),
        expect: () => [],
      );

      blocTest<ProductListCubit, ProductListState>(
        'does nothing when canLoadMore is false',
        build: () => cubit,
        seed: () => ProductListLoaded(
          products: initialProducts,
          meta: const PaginationMeta(total: 2, limit: 20, offset: 0),
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [],
      );

      blocTest<ProductListCubit, ProductListState>(
        'emits Error with previousProducts when loadMore fails',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return cubit;
        },
        seed: () => ProductListLoaded(
          products: initialProducts,
          meta: const PaginationMeta(total: 10, limit: 2, offset: 0),
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [
          ProductListLoading(isLoadingMore: true, existingProducts: initialProducts),
          ProductListError(message: 'Server error', previousProducts: initialProducts),
        ],
      );
    });

    group('refresh', () {
      blocTest<ProductListCubit, ProductListState>(
        'calls fetchProducts with current filters',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer(
            (_) async => Right(createTestProductsResult(products: createTestProducts(2))),
          );
          return cubit;
        },
        seed: () => ProductListLoaded(
          products: createTestProducts(2),
          meta: const PaginationMeta(total: 2, limit: 20, offset: 0),
          searchQuery: 'test',
          categoryFilter: 'Electronics',
        ),
        act: (cubit) => cubit.refresh(),
        verify: (_) {
          final captured = verify(() => mockGetProducts(captureAny())).captured;
          final params = captured.first as GetProductsParams;
          expect(params.search, 'test');
          expect(params.category, 'Electronics');
        },
      );
    });

    group('search', () {
      blocTest<ProductListCubit, ProductListState>(
        'fetches products with search query',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer(
            (_) async => Right(createTestProductsResult(products: createTestProducts(1))),
          );
          return cubit;
        },
        act: (cubit) => cubit.search('laptop'),
        verify: (_) {
          final captured = verify(() => mockGetProducts(captureAny())).captured;
          final params = captured.first as GetProductsParams;
          expect(params.search, 'laptop');
        },
      );

      blocTest<ProductListCubit, ProductListState>(
        'fetches all products when query is empty',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer(
            (_) async => Right(createTestProductsResult(products: createTestProducts(3))),
          );
          return cubit;
        },
        act: (cubit) => cubit.search(''),
        verify: (_) {
          final captured = verify(() => mockGetProducts(captureAny())).captured;
          final params = captured.first as GetProductsParams;
          expect(params.search, isNull);
        },
      );
    });

    group('filterByCategory', () {
      blocTest<ProductListCubit, ProductListState>(
        'fetches products with category filter',
        build: () {
          when(() => mockGetProducts(any())).thenAnswer(
            (_) async => Right(createTestProductsResult(products: createTestProducts(2))),
          );
          return cubit;
        },
        act: (cubit) => cubit.filterByCategory('Electronics'),
        verify: (_) {
          final captured = verify(() => mockGetProducts(captureAny())).captured;
          final params = captured.first as GetProductsParams;
          expect(params.category, 'Electronics');
        },
      );
    });

    group('removeProduct', () {
      final products = createTestProducts(3);

      blocTest<ProductListCubit, ProductListState>(
        'removes product from list',
        build: () => cubit,
        seed: () => ProductListLoaded(
          products: products,
          meta: const PaginationMeta(total: 3, limit: 20, offset: 0),
        ),
        act: (cubit) => cubit.removeProduct(2),
        expect: () => [
          ProductListLoaded(
            products: products.where((p) => p.id != 2).toList(),
            meta: const PaginationMeta(total: 3, limit: 20, offset: 0),
          ),
        ],
      );

      blocTest<ProductListCubit, ProductListState>(
        'does nothing when not in Loaded state',
        build: () => cubit,
        seed: () => const ProductListLoading(),
        act: (cubit) => cubit.removeProduct(1),
        expect: () => [],
      );
    });

    group('addProduct', () {
      final existingProducts = createTestProducts(2);
      final newProduct = createTestProduct(id: 99, name: 'New Product');

      blocTest<ProductListCubit, ProductListState>(
        'adds product to beginning of list',
        build: () => cubit,
        seed: () => ProductListLoaded(
          products: existingProducts,
          meta: const PaginationMeta(total: 2, limit: 20, offset: 0),
        ),
        act: (cubit) => cubit.addProduct(newProduct),
        expect: () => [
          ProductListLoaded(
            products: [newProduct, ...existingProducts],
            meta: const PaginationMeta(total: 2, limit: 20, offset: 0),
          ),
        ],
      );

      blocTest<ProductListCubit, ProductListState>(
        'does nothing when not in Loaded state',
        build: () => cubit,
        seed: () => const ProductListLoading(),
        act: (cubit) => cubit.addProduct(newProduct),
        expect: () => [],
      );
    });

    group('updateProduct', () {
      final products = createTestProducts(3);
      final updatedProduct = createTestProduct(id: 2, name: 'Updated Product');

      blocTest<ProductListCubit, ProductListState>(
        'updates product in list',
        build: () => cubit,
        seed: () => ProductListLoaded(
          products: products,
          meta: const PaginationMeta(total: 3, limit: 20, offset: 0),
        ),
        act: (cubit) => cubit.updateProduct(updatedProduct),
        expect: () => [
          ProductListLoaded(
            products: products.map((p) => p.id == 2 ? updatedProduct : p).toList(),
            meta: const PaginationMeta(total: 3, limit: 20, offset: 0),
          ),
        ],
      );

      blocTest<ProductListCubit, ProductListState>(
        'does nothing when not in Loaded state',
        build: () => cubit,
        seed: () => const ProductListLoading(),
        act: (cubit) => cubit.updateProduct(updatedProduct),
        expect: () => [],
      );
    });
  });
}
