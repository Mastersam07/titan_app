import 'package:dio/dio.dart';

import '../../core/api_constants.dart';
import '../../core/failures.dart';
import '../../models/api_response.dart';
import '../../models/product.dart';

/// API Provider handles all HTTP communication
class ApiProvider {
  ApiProvider({Dio? dio}) : _dio = dio ?? _createDio();
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

    // Add logging interceptor for debugging
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  /// Get all products with optional filters
  Future<ProductsResponse> getProducts({
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

      return ProductsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get single product by ID
  Future<ProductResponse> getProduct(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.products}/$id');
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new product
  Future<ProductResponse> createProduct(Product product) async {
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
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update an existing product
  Future<ProductResponse> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.products}/$id',
        data: data,
      );
      return ProductResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.products}/$id');
      final data = response.data as Map<String, dynamic>;
      return data['success'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check API health
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get(ApiConstants.health);
      final data = response.data as Map<String, dynamic>;
      return data['success'] as bool? ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to Failures
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout. Please try again.');

      case DioExceptionType.connectionError:
        return const NetworkFailure('Unable to connect to server. Please check your connection.');

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return const ClientFailure(message: 'Request cancelled');

      default:
        return NetworkFailure(error.message ?? 'Network error occurred');
    }
  }

  /// Handle HTTP response errors
  Failure _handleResponseError(Response? response) {
    if (response == null) {
      return const ServerFailure('No response from server');
    }

    final statusCode = response.statusCode ?? 0;
    String message = 'Request failed';

    // Try to extract error message from response
    if (response.data is Map<String, dynamic>) {
      final error = response.data['error'] as Map<String, dynamic>?;
      message = error?['message'] as String? ?? message;
    }

    switch (statusCode) {
      case 400:
        return ClientFailure(message: message, statusCode: 400);
      case 404:
        return NotFoundFailure(message);
      case 422:
        return ValidationFailure(message);
      case 500:
      case 502:
      case 503:
        return ServerFailure(message);
      default:
        return ClientFailure(message: message, statusCode: statusCode);
    }
  }
}
