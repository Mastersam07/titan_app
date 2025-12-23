import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required this.remoteDataSource,
  });

  final ProductRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, ProductsResult>> getProducts(GetProductsParams params) async {
    try {
      final result = await remoteDataSource.getProducts(
        limit: params.limit,
        offset: params.offset,
        category: params.category,
        search: params.search,
      );

      return Right(ProductsResult(
        products: result.products,
        meta: result.meta,
      ));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProduct(int id) async {
    try {
      final product = await remoteDataSource.getProduct(id);
      return Right(product);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> createProduct(Product product) async {
    try {
      final createdProduct = await remoteDataSource.createProduct(product);
      return Right(createdProduct);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final updatedProduct = await remoteDataSource.updateProduct(id, data);
      return Right(updatedProduct);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteProduct(int id) async {
    try {
      final success = await remoteDataSource.deleteProduct(id);
      return Right(success);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
