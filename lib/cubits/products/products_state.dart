import 'package:equatable/equatable.dart';

import '../../models/api_response.dart';
import '../../models/product.dart';

/// Sealed base state for products - enables exhaustive pattern matching
sealed class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
final class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// Loading state
final class ProductsLoading extends ProductsState {
  const ProductsLoading({
    this.isLoadingMore = false,
    this.existingProducts = const [],
  });

  /// If true, loading more items (pagination)
  final bool isLoadingMore;

  /// Existing products while loading more
  final List<Product> existingProducts;

  @override
  List<Object?> get props => [isLoadingMore, existingProducts];
}

/// Loaded state with products
final class ProductsLoaded extends ProductsState {
  const ProductsLoaded({
    required this.products,
    required this.meta,
    this.searchQuery,
    this.categoryFilter,
  });
  final List<Product> products;
  final PaginationMeta meta;
  final String? searchQuery;
  final String? categoryFilter;

  /// Check if more products can be loaded
  bool get canLoadMore => meta.hasMore;

  /// Get unique categories from products
  List<String> get categories {
    final cats = products.where((p) => p.category != null).map((p) => p.category!).toSet().toList();
    cats.sort();
    return cats;
  }

  /// Create copy with updated products (for pagination)
  ProductsLoaded copyWith({
    List<Product>? products,
    PaginationMeta? meta,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      meta: meta ?? this.meta,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  @override
  List<Object?> get props => [products, meta, searchQuery, categoryFilter];
}

/// Error state
final class ProductsError extends ProductsState {
  const ProductsError({
    required this.message,
    this.previousProducts = const [],
  });
  final String message;
  final List<Product> previousProducts;

  @override
  List<Object?> get props => [message, previousProducts];
}
