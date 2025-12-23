import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

sealed class ProductCreateState extends Equatable {
  const ProductCreateState();

  @override
  List<Object?> get props => [];
}

final class ProductCreateInitial extends ProductCreateState {
  const ProductCreateInitial();
}

final class ProductCreateSubmitting extends ProductCreateState {
  const ProductCreateSubmitting();
}

final class ProductCreateSuccess extends ProductCreateState {
  const ProductCreateSuccess({required this.product});

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductCreateError extends ProductCreateState {
  const ProductCreateError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
