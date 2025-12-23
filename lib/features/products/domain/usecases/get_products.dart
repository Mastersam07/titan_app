import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class GetProducts implements UseCase<ProductsResult, GetProductsParams> {
  const GetProducts(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, ProductsResult>> call(GetProductsParams params) => repository.getProducts(params);
}
