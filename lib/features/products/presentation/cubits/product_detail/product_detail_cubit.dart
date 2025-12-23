import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/delete_product.dart';
import '../../../domain/usecases/get_product.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required GetProduct getProduct,
    required DeleteProduct deleteProduct,
  })  : _getProduct = getProduct,
        _deleteProduct = deleteProduct,
        super(const ProductDetailInitial());

  final GetProduct _getProduct;
  final DeleteProduct _deleteProduct;

  Future<void> loadProduct(int id) async {
    emit(const ProductDetailLoading());

    final result = await _getProduct(id);

    result.fold(
      (failure) => emit(ProductDetailError(message: failure.message)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }

  void setProduct(Product product) {
    emit(ProductDetailLoaded(product: product));
  }

  Future<bool> delete() async {
    final currentState = state;
    if (currentState is! ProductDetailLoaded) {
      return false;
    }

    final product = currentState.product;
    emit(ProductDetailDeleting(product: product));

    final result = await _deleteProduct(product.id);

    return result.fold(
      (failure) {
        emit(ProductDetailError(
          message: failure.message,
          product: product,
        ));
        return false;
      },
      (success) {
        if (success) {
          emit(const ProductDetailDeleted());
        } else {
          emit(ProductDetailError(
            message: 'Failed to delete product',
            product: product,
          ));
        }
        return success;
      },
    );
  }

  void updateProduct(Product product) {
    emit(ProductDetailLoaded(product: product));
  }
}
