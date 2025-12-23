/// API Configuration
///
/// Update [baseUrl] to match your server:
/// - Local development: 'http://localhost:8000'
/// - Android emulator: 'http://10.0.2.2:8000'
/// - iOS simulator: 'http://localhost:8000'
/// - Physical device: 'http://YOUR_MACHINE_IP:8000'
/// - ngrok tunnel: 'https://your-tunnel.ngrok.io'
class ApiConstants {
  ApiConstants._();

  /// Base URL for the API
  /// Change this to your server address
  static const String baseUrl = 'https://titan-api-3f3i.onrender.com/api';

  /// Endpoints
  static const String products = '/products';
  static const String health = '/health';

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
