import 'product.dart';

/// Pagination metadata
class PaginationMeta {
  const PaginationMeta({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int? ?? 0,
      limit: json['limit'] as int? ?? 100,
      offset: json['offset'] as int? ?? 0,
    );
  }
  final int total;
  final int limit;
  final int offset;

  /// Check if there are more items
  bool get hasMore => offset + limit < total;

  /// Next offset for pagination
  int get nextOffset => offset + limit;
}

/// Products list response
class ProductsResponse {
  const ProductsResponse({
    required this.success,
    required this.products,
    required this.meta,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];

    return ProductsResponse(
      success: json['success'] as bool? ?? false,
      products: data.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
  final bool success;
  final List<Product> products;
  final PaginationMeta meta;
}

/// Single product response
class ProductResponse {
  const ProductResponse({
    required this.success,
    required this.product,
    this.message,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] as bool? ?? false,
      product: Product.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }
  final bool success;
  final Product product;
  final String? message;
}

/// Error response
class ErrorResponse {
  const ErrorResponse({
    required this.success,
    required this.code,
    required this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>? ?? {};

    return ErrorResponse(
      success: json['success'] as bool? ?? false,
      code: error['code'] as int? ?? 0,
      message: error['message'] as String? ?? 'Unknown error',
    );
  }
  final bool success;
  final int code;
  final String message;
}
