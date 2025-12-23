import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';

sealed class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

final class ProductDetailInitial extends ProductDetailState {
  const ProductDetailInitial();
}

final class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

final class ProductDetailLoaded extends ProductDetailState {
  const ProductDetailLoaded({required this.product});

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductDetailDeleting extends ProductDetailState {
  const ProductDetailDeleting({required this.product});

  final Product product;

  @override
  List<Object?> get props => [product];
}

final class ProductDetailDeleted extends ProductDetailState {
  const ProductDetailDeleted();
}

final class ProductDetailError extends ProductDetailState {
  const ProductDetailError({
    required this.message,
    this.product,
  });

  final String message;
  final Product? product;

  @override
  List<Object?> get props => [message, product];
}
