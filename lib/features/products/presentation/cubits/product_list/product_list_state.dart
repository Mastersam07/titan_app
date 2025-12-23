import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/repositories/product_repository.dart';

sealed class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object?> get props => [];
}

final class ProductListInitial extends ProductListState {
  const ProductListInitial();
}

final class ProductListLoading extends ProductListState {
  const ProductListLoading({
    this.isLoadingMore = false,
    this.existingProducts = const [],
  });

  final bool isLoadingMore;
  final List<Product> existingProducts;

  @override
  List<Object?> get props => [isLoadingMore, existingProducts];
}

final class ProductListLoaded extends ProductListState {
  const ProductListLoaded({
    required this.products,
    required this.meta,
    this.searchQuery,
    this.categoryFilter,
  });

  final List<Product> products;
  final PaginationMeta meta;
  final String? searchQuery;
  final String? categoryFilter;

  bool get canLoadMore => meta.hasMore;

  List<String> get categories {
    final cats = products.where((p) => p.category != null).map((p) => p.category!).toSet().toList();
    cats.sort();
    return cats;
  }

  ProductListLoaded copyWith({
    List<Product>? products,
    PaginationMeta? meta,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return ProductListLoaded(
      products: products ?? this.products,
      meta: meta ?? this.meta,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  @override
  List<Object?> get props => [products, meta, searchQuery, categoryFilter];
}

final class ProductListError extends ProductListState {
  const ProductListError({
    required this.message,
    this.previousProducts = const [],
  });

  final String message;
  final List<Product> previousProducts;

  @override
  List<Object?> get props => [message, previousProducts];
}
