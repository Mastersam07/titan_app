import 'package:dartz/dartz.dart';

import '../../core/failures.dart';
import '../../models/api_response.dart';
import '../../models/product.dart';
import '../providers/api_provider.dart';

/// Repository for product operations
///
/// Wraps [ApiProvider] and returns [Either] for functional error handling
class ProductRepository {
  ProductRepository({ApiProvider? apiProvider}) : _apiProvider = apiProvider ?? ApiProvider();
  final ApiProvider _apiProvider;

  /// Fetch all products
  Future<Either<Failure, ProductsResponse>> getProducts({
    int? limit,
    int? offset,
    String? category,
    String? search,
  }) async {
    try {
      final response = await _apiProvider.getProducts(
        limit: limit,
        offset: offset,
        category: category,
        search: search,
      );
      return Right(response);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Fetch single product
  Future<Either<Failure, Product>> getProduct(int id) async {
    try {
      final response = await _apiProvider.getProduct(id);
      return Right(response.product);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Create new product
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final response = await _apiProvider.createProduct(product);
      return Right(response.product);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Update product
  Future<Either<Failure, Product>> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiProvider.updateProduct(id, data);
      return Right(response.product);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Delete product
  Future<Either<Failure, bool>> deleteProduct(int id) async {
    try {
      final success = await _apiProvider.deleteProduct(id);
      return Right(success);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Check API health
  Future<Either<Failure, bool>> checkHealth() async {
    try {
      final healthy = await _apiProvider.checkHealth();
      return Right(healthy);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
