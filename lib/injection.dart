import 'package:get_it/get_it.dart';

import 'features/products/data/datasources/product_remote_datasource.dart';
import 'features/products/data/repositories/product_repository_impl.dart';
import 'features/products/domain/repositories/product_repository.dart';
import 'features/products/domain/usecases/create_product.dart';
import 'features/products/domain/usecases/delete_product.dart';
import 'features/products/domain/usecases/get_product.dart';
import 'features/products/domain/usecases/get_products.dart';
import 'features/products/domain/usecases/update_product.dart';
import 'features/products/presentation/cubits/product_create/product_create_cubit.dart';
import 'features/products/presentation/cubits/product_detail/product_detail_cubit.dart';
import 'features/products/presentation/cubits/product_edit/product_edit_cubit.dart';
import 'features/products/presentation/cubits/product_list/product_list_cubit.dart';

final di = GetIt.instance;

void setupDependencies() {
  di.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImpl());

  di.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(remoteDataSource: di()));

  di.registerLazySingleton(() => GetProducts(di()));
  di.registerLazySingleton(() => GetProduct(di()));
  di.registerLazySingleton(() => CreateProduct(di()));
  di.registerLazySingleton(() => UpdateProduct(di()));
  di.registerLazySingleton(() => DeleteProduct(di()));

  di.registerFactory<ProductListCubit>(() => ProductListCubit(getProducts: di()));

  di.registerFactory<ProductDetailCubit>(() => ProductDetailCubit(getProduct: di(), deleteProduct: di()));

  di.registerFactory<ProductCreateCubit>(() => ProductCreateCubit(createProduct: di()));

  di.registerFactory<ProductEditCubit>(() => ProductEditCubit(getProduct: di(), updateProduct: di()));
}
