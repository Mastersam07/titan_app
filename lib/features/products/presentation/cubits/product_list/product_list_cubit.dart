import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/get_products.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  ProductListCubit({
    required GetProducts getProducts,
  })  : _getProducts = getProducts,
        super(const ProductListInitial());

  final GetProducts _getProducts;

  Future<void> fetchProducts({
    String? category,
    String? search,
    int limit = 20,
  }) async {
    emit(const ProductListLoading());

    final result = await _getProducts(GetProductsParams(
      limit: limit,
      offset: 0,
      category: category,
      search: search,
    ));

    result.fold(
      (failure) => emit(ProductListError(message: failure.message)),
      (productsResult) => emit(ProductListLoaded(
        products: productsResult.products,
        meta: productsResult.meta,
        searchQuery: search,
        categoryFilter: category,
      )),
    );
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ProductListLoaded || !currentState.canLoadMore) {
      return;
    }

    emit(ProductListLoading(
      isLoadingMore: true,
      existingProducts: currentState.products,
    ));

    final result = await _getProducts(GetProductsParams(
      limit: 20,
      offset: currentState.meta.nextOffset,
      category: currentState.categoryFilter,
      search: currentState.searchQuery,
    ));

    result.fold(
      (failure) => emit(ProductListError(
        message: failure.message,
        previousProducts: currentState.products,
      )),
      (productsResult) => emit(ProductListLoaded(
        products: [...currentState.products, ...productsResult.products],
        meta: productsResult.meta,
        searchQuery: currentState.searchQuery,
        categoryFilter: currentState.categoryFilter,
      )),
    );
  }

  Future<void> refresh() async {
    final currentState = state;
    String? category;
    String? search;

    if (currentState is ProductListLoaded) {
      category = currentState.categoryFilter;
      search = currentState.searchQuery;
    }

    await fetchProducts(category: category, search: search);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await fetchProducts();
    } else {
      await fetchProducts(search: query);
    }
  }

  Future<void> filterByCategory(String? category) async {
    await fetchProducts(category: category);
  }

  void removeProduct(int id) {
    if (state is ProductListLoaded) {
      final loaded = state as ProductListLoaded;
      final updatedProducts = loaded.products.where((p) => p.id != id).toList();
      emit(loaded.copyWith(products: updatedProducts));
    }
  }

  void addProduct(Product product) {
    if (state is ProductListLoaded) {
      final loaded = state as ProductListLoaded;
      emit(loaded.copyWith(products: [product, ...loaded.products]));
    }
  }

  void updateProduct(Product product) {
    if (state is ProductListLoaded) {
      final loaded = state as ProductListLoaded;
      final updatedProducts = loaded.products.map((p) => p.id == product.id ? product : p).toList();
      emit(loaded.copyWith(products: updatedProducts));
    }
  }
}
