import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

class DeleteProduct implements UseCase<bool, int> {
  const DeleteProduct(this.repository);

  final ProductRepository repository;

  @override
  Future<Either<Failure, bool>> call(int id) => repository.deleteProduct(id);
}
