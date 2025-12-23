import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProduct implements UseCase<Product, int> {
  const GetProduct(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, Product>> call(int id) => repository.getProduct(id);
}
