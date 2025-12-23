import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/create_product.dart';
import 'product_create_state.dart';

class ProductCreateCubit extends Cubit<ProductCreateState> {
  ProductCreateCubit({
    required CreateProduct createProduct,
  })  : _createProduct = createProduct,
        super(const ProductCreateInitial());

  final CreateProduct _createProduct;

  Future<void> create({
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    required int stockQuantity,
    String? category,
  }) async {
    emit(const ProductCreateSubmitting());

    final product = Product(
      id: 0, // Will be assigned by server
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      stockQuantity: stockQuantity,
      category: category,
    );

    final result = await _createProduct(product);

    result.fold(
      (failure) => emit(ProductCreateError(message: failure.message)),
      (createdProduct) => emit(ProductCreateSuccess(product: createdProduct)),
    );
  }

  void reset() {
    emit(const ProductCreateInitial());
  }
}
