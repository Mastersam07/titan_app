import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_product.dart';
import '../../../domain/usecases/update_product.dart';
import 'product_edit_state.dart';

class ProductEditCubit extends Cubit<ProductEditState> {
  ProductEditCubit({
    required GetProduct getProduct,
    required UpdateProduct updateProduct,
  })  : _getProduct = getProduct,
        _updateProduct = updateProduct,
        super(const ProductEditInitial());

  final GetProduct _getProduct;
  final UpdateProduct _updateProduct;

  Future<void> loadProduct(int id) async {
    emit(const ProductEditLoading());

    final result = await _getProduct(id);

    result.fold(
      (failure) => emit(ProductEditError(message: failure.message)),
      (product) => emit(ProductEditLoaded(product: product)),
    );
  }

  void setProduct(Product product) {
    emit(ProductEditLoaded(product: product));
  }

  Future<void> update({
    required int id,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    required int stockQuantity,
    String? category,
  }) async {
    final currentState = state;
    Product? currentProduct;

    if (currentState is ProductEditLoaded) {
      currentProduct = currentState.product;
    } else if (currentState is ProductEditError) {
      currentProduct = currentState.product;
    }

    if (currentProduct != null) {
      emit(ProductEditSubmitting(product: currentProduct));
    }

    final data = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'category': category,
    };

    final result = await _updateProduct(UpdateProductParams(id: id, data: data));

    result.fold(
      (failure) => emit(ProductEditError(
        message: failure.message,
        product: currentProduct,
      )),
      (updatedProduct) => emit(ProductEditSuccess(product: updatedProduct)),
    );
  }

  void reset() {
    emit(const ProductEditInitial());
  }
}
