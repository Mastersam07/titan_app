class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://titan-api-3f3i.onrender.com/api';

  static const String products = '/products';
  static const String health = '/health';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
