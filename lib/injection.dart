import 'package:get_it/get_it.dart';

import 'data/providers/api_provider.dart';
import 'data/repositories/product_repository.dart';
import 'cubits/products/products_cubit.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
void setupDependencies() {
  // Providers
  getIt.registerLazySingleton<ApiProvider>(() => ApiProvider());

  // Repositories
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(apiProvider: getIt<ApiProvider>()),
  );

  // Cubits
  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(repository: getIt<ProductRepository>()),
  );
}
