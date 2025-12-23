import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}

/// Server-side failures (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Network failures (no connection, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

/// Client-side failures (4xx errors)
class ClientFailure extends Failure {
  const ClientFailure({
    String message = 'Request failed',
    this.statusCode,
  }) : super(message);
  final int? statusCode;

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

/// Not found failures (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

/// Validation failures (422)
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed']);
}

/// Cache failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}
