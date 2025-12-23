import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class UpdateProductParams {
  const UpdateProductParams({
    required this.id,
    required this.data,
  });

  final int id;
  final Map<String, dynamic> data;
}

class UpdateProduct implements UseCase<Product, UpdateProductParams> {
  const UpdateProduct(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, Product>> call(UpdateProductParams params) {
    return repository.updateProduct(params.id, params.data);
  }
}
