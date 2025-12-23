import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProduct implements UseCase<Product, Product> {
  const CreateProduct(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, Product>> call(Product product) => repository.createProduct(product);
}
