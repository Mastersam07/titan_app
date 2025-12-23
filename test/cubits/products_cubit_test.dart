import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:titan_flutter/core/failures.dart';
import 'package:titan_flutter/cubits/products/products_cubit.dart';
import 'package:titan_flutter/cubits/products/products_state.dart';
import 'package:titan_flutter/data/repositories/product_repository.dart';
import 'package:titan_flutter/models/api_response.dart';
import 'package:titan_flutter/models/product.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository mockRepository;

  final testProducts = [
    const Product(id: 1, name: 'Product 1', price: 99.99, category: 'Electronics'),
    const Product(id: 2, name: 'Product 2', price: 149.99, category: 'Furniture'),
    const Product(id: 3, name: 'Product 3', price: 199.99, category: 'Electronics'),
  ];

  final testResponse = ProductsResponse(
    success: true,
    products: testProducts,
    meta: const PaginationMeta(total: 10, limit: 3, offset: 0),
  );

  setUp(() {
    mockRepository = MockProductRepository();
  });

  group('ProductsCubit', () {
    test('initial state is ProductsInitial', () {
      final cubit = ProductsCubit(repository: mockRepository);
      expect(cubit.state, const ProductsInitial());
      cubit.close();
    });

    group('fetchProducts', () {
      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsLoaded] when successful',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: any(named: 'category'),
                search: any(named: 'search'),
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.fetchProducts(),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'products count', 3)
              .having((s) => s.meta.total, 'total', 10)
              .having((s) => s.canLoadMore, 'canLoadMore', true),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits [ProductsLoading, ProductsError] when fails',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: any(named: 'category'),
                search: any(named: 'search'),
              )).thenAnswer((_) async => const Left(NetworkFailure('No internet')));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.fetchProducts(),
        expect: () => [
          const ProductsLoading(),
          isA<ProductsError>().having((s) => s.message, 'message', 'No internet'),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'passes category filter to repository',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: 'Electronics',
                search: any(named: 'search'),
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.fetchProducts(category: 'Electronics'),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: 'Electronics',
                search: null,
              )).called(1);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'passes search query to repository',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: any(named: 'category'),
                search: 'phone',
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.fetchProducts(search: 'phone'),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: null,
                search: 'phone',
              )).called(1);
        },
      );
    });

    group('loadMore', () {
      blocTest<ProductsCubit, ProductsState>(
        'loads more products when canLoadMore is true',
        build: () {
          when(() => mockRepository.getProducts(
                limit: 20,
                offset: 3,
                category: null,
                search: null,
              )).thenAnswer((_) async => const Right(ProductsResponse(
                success: true,
                products: [Product(id: 4, name: 'Product 4', price: 249.99)],
                meta: PaginationMeta(total: 10, limit: 20, offset: 3),
              )));
          return ProductsCubit(repository: mockRepository);
        },
        seed: () => ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 10, limit: 3, offset: 0),
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [
          isA<ProductsLoading>()
              .having((s) => s.isLoadingMore, 'isLoadingMore', true)
              .having((s) => s.existingProducts.length, 'existing count', 3),
          isA<ProductsLoaded>().having((s) => s.products.length, 'products count', 4),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'does nothing when canLoadMore is false',
        build: () => ProductsCubit(repository: mockRepository),
        seed: () => ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ),
        act: (cubit) => cubit.loadMore(),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: any(named: 'category'),
                search: any(named: 'search'),
              ));
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'does nothing when state is not ProductsLoaded',
        build: () => ProductsCubit(repository: mockRepository),
        act: (cubit) => cubit.loadMore(),
        expect: () => [],
      );

      blocTest<ProductsCubit, ProductsState>(
        'preserves search/category filters when loading more',
        build: () {
          when(() => mockRepository.getProducts(
                limit: 20,
                offset: 3,
                category: 'Electronics',
                search: 'phone',
              )).thenAnswer((_) async => const Right(ProductsResponse(
                success: true,
                products: [],
                meta: PaginationMeta(total: 3, limit: 20, offset: 3),
              )));
          return ProductsCubit(repository: mockRepository);
        },
        seed: () => ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 10, limit: 3, offset: 0),
          categoryFilter: 'Electronics',
          searchQuery: 'phone',
        ),
        act: (cubit) => cubit.loadMore(),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 3,
                category: 'Electronics',
                search: 'phone',
              )).called(1);
        },
      );
    });

    group('search', () {
      blocTest<ProductsCubit, ProductsState>(
        'fetches products with search query',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: any(named: 'category'),
                search: 'laptop',
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.search('laptop'),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: null,
                search: 'laptop',
              )).called(1);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'fetches all products when search is empty',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: any(named: 'category'),
                search: any(named: 'search'),
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.search(''),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: null,
                search: null,
              )).called(1);
        },
      );
    });

    group('filterByCategory', () {
      blocTest<ProductsCubit, ProductsState>(
        'fetches products filtered by category',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: 'Electronics',
                search: any(named: 'search'),
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.filterByCategory('Electronics'),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: 'Electronics',
                search: null,
              )).called(1);
        },
      );

      blocTest<ProductsCubit, ProductsState>(
        'clears category filter when null',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: null,
                search: any(named: 'search'),
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        act: (cubit) => cubit.filterByCategory(null),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: null,
                search: null,
              )).called(1);
        },
      );
    });

    group('refresh', () {
      blocTest<ProductsCubit, ProductsState>(
        'refreshes with current filters',
        build: () {
          when(() => mockRepository.getProducts(
                limit: any(named: 'limit'),
                offset: any(named: 'offset'),
                category: 'Electronics',
                search: 'phone',
              )).thenAnswer((_) async => Right(testResponse));
          return ProductsCubit(repository: mockRepository);
        },
        seed: () => ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
          categoryFilter: 'Electronics',
          searchQuery: 'phone',
        ),
        act: (cubit) => cubit.refresh(),
        verify: (_) {
          verify(() => mockRepository.getProducts(
                limit: 20,
                offset: 0,
                category: 'Electronics',
                search: 'phone',
              )).called(1);
        },
      );
    });

    group('deleteProduct', () {
      blocTest<ProductsCubit, ProductsState>(
        'removes product from list on success',
        build: () {
          when(() => mockRepository.deleteProduct(1)).thenAnswer((_) async => const Right(true));
          return ProductsCubit(repository: mockRepository);
        },
        seed: () => ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ),
        act: (cubit) => cubit.deleteProduct(1),
        expect: () => [
          isA<ProductsLoaded>()
              .having((s) => s.products.length, 'products count', 2)
              .having((s) => s.products.any((p) => p.id == 1), 'contains deleted', false),
        ],
      );

      blocTest<ProductsCubit, ProductsState>(
        'emits error but preserves products on failure',
        build: () {
          when(() => mockRepository.deleteProduct(1))
              .thenAnswer((_) async => const Left(ServerFailure('Delete failed')));
          return ProductsCubit(repository: mockRepository);
        },
        seed: () => ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ),
        act: (cubit) => cubit.deleteProduct(1),
        expect: () => [
          isA<ProductsError>()
              .having((s) => s.message, 'message', 'Delete failed')
              .having((s) => s.previousProducts.length, 'previous count', 3),
        ],
      );

      test('returns true on successful delete', () async {
        when(() => mockRepository.deleteProduct(1)).thenAnswer((_) async => const Right(true));

        final cubit = ProductsCubit(repository: mockRepository);
        cubit.emit(ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ));

        final result = await cubit.deleteProduct(1);

        expect(result, true);
        cubit.close();
      });

      test('returns false on failed delete', () async {
        when(() => mockRepository.deleteProduct(1)).thenAnswer((_) async => const Left(ServerFailure('Failed')));

        final cubit = ProductsCubit(repository: mockRepository);
        cubit.emit(ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ));

        final result = await cubit.deleteProduct(1);

        expect(result, false);
        cubit.close();
      });
    });

    group('addProduct', () {
      test('adds product to beginning of list', () {
        final cubit = ProductsCubit(repository: mockRepository);
        cubit.emit(ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ));

        const newProduct = Product(id: 10, name: 'New Product', price: 299.99);
        cubit.addProduct(newProduct);

        final state = cubit.state as ProductsLoaded;
        expect(state.products.first.id, 10);
        expect(state.products.length, 4);
        cubit.close();
      });

      test('does nothing when state is not ProductsLoaded', () {
        final cubit = ProductsCubit(repository: mockRepository);

        const newProduct = Product(id: 10, name: 'New Product', price: 299.99);
        cubit.addProduct(newProduct);

        expect(cubit.state, const ProductsInitial());
        cubit.close();
      });
    });

    group('updateProduct', () {
      test('updates existing product in list', () {
        final cubit = ProductsCubit(repository: mockRepository);
        cubit.emit(ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ));

        final updatedProduct = testProducts[0].copyWith(name: 'Updated Name');
        cubit.updateProduct(updatedProduct);

        final state = cubit.state as ProductsLoaded;
        expect(state.products.first.name, 'Updated Name');
        expect(state.products.length, 3);
        cubit.close();
      });

      test('does nothing when product not in list', () {
        final cubit = ProductsCubit(repository: mockRepository);
        cubit.emit(ProductsLoaded(
          products: testProducts,
          meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
        ));

        const unknownProduct = Product(id: 999, name: 'Unknown', price: 0);
        cubit.updateProduct(unknownProduct);

        final state = cubit.state as ProductsLoaded;
        expect(state.products.any((p) => p.id == 999), false);
        cubit.close();
      });
    });
  });

  group('ProductsState', () {
    test('ProductsLoaded.categories returns unique sorted categories', () {
      final state = ProductsLoaded(
        products: testProducts,
        meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
      );

      expect(state.categories, ['Electronics', 'Furniture']);
    });

    test('ProductsLoaded.canLoadMore is true when more items exist', () {
      final state = ProductsLoaded(
        products: testProducts,
        meta: const PaginationMeta(total: 10, limit: 3, offset: 0),
      );

      expect(state.canLoadMore, true);
    });

    test('ProductsLoaded.canLoadMore is false when all items loaded', () {
      final state = ProductsLoaded(
        products: testProducts,
        meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
      );

      expect(state.canLoadMore, false);
    });

    test('ProductsLoaded.copyWith creates new instance with updated values', () {
      final state = ProductsLoaded(
        products: testProducts,
        meta: const PaginationMeta(total: 3, limit: 3, offset: 0),
      );

      final newState = state.copyWith(searchQuery: 'test');

      expect(newState.searchQuery, 'test');
      expect(newState.products, state.products);
    });
  });
}
