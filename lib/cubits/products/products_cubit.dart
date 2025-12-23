import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/product_repository.dart';
import '../../models/product.dart';
import 'products_state.dart';

/// Cubit for managing products list
class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit({ProductRepository? repository})
      : _repository = repository ?? ProductRepository(),
        super(const ProductsInitial());
  final ProductRepository _repository;

  /// Fetch products (initial load or refresh)
  Future<void> fetchProducts({
    String? category,
    String? search,
    int limit = 20,
  }) async {
    emit(const ProductsLoading());

    final result = await _repository.getProducts(
      limit: limit,
      offset: 0,
      category: category,
      search: search,
    );

    result.fold(
      (failure) => emit(ProductsError(message: failure.message)),
      (response) => emit(ProductsLoaded(
        products: response.products,
        meta: response.meta,
        searchQuery: search,
        categoryFilter: category,
      )),
    );
  }

  /// Load more products (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ProductsLoaded || !currentState.canLoadMore) {
      return;
    }

    emit(ProductsLoading(
      isLoadingMore: true,
      existingProducts: currentState.products,
    ));

    final result = await _repository.getProducts(
      limit: 20,
      offset: currentState.meta.nextOffset,
      category: currentState.categoryFilter,
      search: currentState.searchQuery,
    );

    result.fold(
      (failure) => emit(ProductsError(
        message: failure.message,
        previousProducts: currentState.products,
      )),
      (response) => emit(ProductsLoaded(
        products: [...currentState.products, ...response.products],
        meta: response.meta,
        searchQuery: currentState.searchQuery,
        categoryFilter: currentState.categoryFilter,
      )),
    );
  }

  /// Refresh products
  Future<void> refresh() async {
    final currentState = state;
    String? category;
    String? search;

    if (currentState is ProductsLoaded) {
      category = currentState.categoryFilter;
      search = currentState.searchQuery;
    }

    await fetchProducts(category: category, search: search);
  }

  /// Search products
  Future<void> search(String query) async {
    if (query.isEmpty) {
      await fetchProducts();
    } else {
      await fetchProducts(search: query);
    }
  }

  /// Filter by category
  Future<void> filterByCategory(String? category) async {
    await fetchProducts(category: category);
  }

  /// Delete a product
  Future<bool> deleteProduct(int id) async {
    final result = await _repository.deleteProduct(id);

    return result.fold(
      (failure) {
        // Emit error but keep current products
        if (state is ProductsLoaded) {
          final loaded = state as ProductsLoaded;
          emit(ProductsError(
            message: failure.message,
            previousProducts: loaded.products,
          ));
        }
        return false;
      },
      (success) {
        if (success && state is ProductsLoaded) {
          final loaded = state as ProductsLoaded;
          final updatedProducts = loaded.products.where((p) => p.id != id).toList();
          emit(loaded.copyWith(products: updatedProducts));
        }
        return success;
      },
    );
  }

  /// Add a product to the list (after creation)
  void addProduct(Product product) {
    if (state is ProductsLoaded) {
      final loaded = state as ProductsLoaded;
      emit(loaded.copyWith(products: [product, ...loaded.products]));
    }
  }

  /// Update a product in the list
  void updateProduct(Product product) {
    if (state is ProductsLoaded) {
      final loaded = state as ProductsLoaded;
      final updatedProducts = loaded.products.map((p) {
        return p.id == product.id ? product : p;
      }).toList();
      emit(loaded.copyWith(products: updatedProducts));
    }
  }
}
