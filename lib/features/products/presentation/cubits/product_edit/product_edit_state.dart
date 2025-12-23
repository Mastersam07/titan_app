import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

sealed class ProductEditState extends Equatable {
  const ProductEditState();

  @override
  List<Object?> get props => [];
}

final class ProductEditInitial extends ProductEditState {
  const ProductEditInitial();
}

final class ProductEditLoading extends ProductEditState {
  const ProductEditLoading();
}

final class ProductEditLoaded extends ProductEditState {
  const ProductEditLoaded({required this.product});

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductEditSubmitting extends ProductEditState {
  const ProductEditSubmitting({required this.product});

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductEditSuccess extends ProductEditState {
  const ProductEditSuccess({required this.product});

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductEditError extends ProductEditState {
  const ProductEditError({
    required this.message,
    this.product,
  });

  final String message;
  final Product? product;

  @override
  List<Object?> get props => [message, product];
}
