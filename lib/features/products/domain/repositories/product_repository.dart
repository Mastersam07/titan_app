import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../entities/product.dart';

class GetProductsParams {
  const GetProductsParams({
    this.limit,
    this.offset,
    this.category,
    this.search,
  });

  final int? limit;
  final int? offset;
  final String? category;
  final String? search;
}

class PaginationMeta extends Equatable {
  const PaginationMeta({
    required this.total,
    required this.limit,
    required this.offset,
  });

  final int total;
  final int limit;
  final int offset;

  bool get hasMore => offset + limit < total;
  int get nextOffset => offset + limit;

  @override
  List<Object?> get props => [total, limit, offset];
}

class ProductsResult {
  const ProductsResult({
    required this.products,
    required this.meta,
  });

  final List<Product> products;
  final PaginationMeta meta;
}

abstract class ProductRepository {
  Future<Either<Failure, ProductsResult>> getProducts(GetProductsParams params);
  Future<Either<Failure, Product>> getProduct(int id);
  Future<Either<Failure, Product>> createProduct(Product product);
  Future<Either<Failure, Product>> updateProduct(int id, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteProduct(int id);
}
