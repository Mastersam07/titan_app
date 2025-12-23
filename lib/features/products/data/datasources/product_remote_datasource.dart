import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_constants.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<ProductsDataResult> getProducts({
    int? limit,
    int? offset,
    String? category,
    String? search,
  });

  Future<ProductModel> getProduct(int id);
  Future<ProductModel> createProduct(Product product);
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data);
  Future<bool> deleteProduct(int id);
}

class ProductsDataResult {
  const ProductsDataResult({
    required this.products,
    required this.meta,
  });

  final List<ProductModel> products;
  final PaginationMeta meta;
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  @override
  Future<ProductsDataResult> getProducts({
    int? limit,
    int? offset,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        ApiConstants.products,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data as Map<String, dynamic>;
      final productsList = data['data'] as List<dynamic>? ?? [];
      final metaJson = data['meta'] as Map<String, dynamic>? ?? {};

      return ProductsDataResult(
        products: productsList.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList(),
        meta: PaginationMeta(
          total: metaJson['total'] as int? ?? 0,
          limit: metaJson['limit'] as int? ?? 100,
          offset: metaJson['offset'] as int? ?? 0,
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.products}/$id');
      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductModel> createProduct(Product product) async {
    try {
      final response = await _dio.post(
        ApiConstants.products,
        data: {
          'name': product.name,
          'description': product.description,
          'price': product.price,
          'image_url': product.imageUrl,
          'stock_quantity': product.stockQuantity,
          'category': product.category,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ProductModel> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.products}/$id',
        data: data,
      );
      final responseData = response.data as Map<String, dynamic>;
      return ProductModel.fromJson(responseData['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.products}/$id');
      final data = response.data as Map<String, dynamic>;
      return data['success'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException error) => switch (error.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          const NetworkFailure('Connection timeout. Please try again.'),
        DioExceptionType.connectionError =>
          const NetworkFailure('Unable to connect to server. Please check your connection.'),
        DioExceptionType.badResponse => _handleResponseError(error.response),
        DioExceptionType.cancel => const ClientFailure(message: 'Request cancelled'),
        _ => NetworkFailure(error.message ?? 'Network error occurred')
      };

  Failure _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerFailure('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    String message = 'Request failed';

    if (response.data is Map<String, dynamic>) {
      final error = response.data['error'] as Map<String, dynamic>?;
      message = error?['message'] as String? ?? message;
    }

    return switch (statusCode) {
      400 => ClientFailure(message: message, statusCode: 400),
      404 => NotFoundFailure(message),
      422 => ValidationFailure(message),
      500 || 502 || 503 => ServerFailure(message),
      _ => ClientFailure(message: message, statusCode: statusCode)
    };
  }
}
