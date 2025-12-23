import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/core/failures.dart';

void main() {
  group('Failures', () {
    group('ServerFailure', () {
      test('has default message', () {
        const failure = ServerFailure();
        expect(failure.message, 'Server error occurred');
      });

      test('accepts custom message', () {
        const failure = ServerFailure('Custom server error');
        expect(failure.message, 'Custom server error');
      });

      test('equality works correctly', () {
        const failure1 = ServerFailure('Error');
        const failure2 = ServerFailure('Error');
        const failure3 = ServerFailure('Different');

        expect(failure1, failure2);
        expect(failure1, isNot(failure3));
      });
    });

    group('NetworkFailure', () {
      test('has default message', () {
        const failure = NetworkFailure();
        expect(failure.message, 'Network error. Please check your connection.');
      });

      test('accepts custom message', () {
        const failure = NetworkFailure('No internet');
        expect(failure.message, 'No internet');
      });
    });

    group('ClientFailure', () {
      test('has default message', () {
        const failure = ClientFailure();
        expect(failure.message, 'Request failed');
      });

      test('accepts custom message and status code', () {
        const failure = ClientFailure(message: 'Bad request', statusCode: 400);
        expect(failure.message, 'Bad request');
        expect(failure.statusCode, 400);
      });

      test('equality includes statusCode', () {
        const failure1 = ClientFailure(message: 'Error', statusCode: 400);
        const failure2 = ClientFailure(message: 'Error', statusCode: 400);
        const failure3 = ClientFailure(message: 'Error', statusCode: 401);

        expect(failure1, failure2);
        expect(failure1, isNot(failure3));
      });
    });

    group('NotFoundFailure', () {
      test('has default message', () {
        const failure = NotFoundFailure();
        expect(failure.message, 'Resource not found');
      });

      test('accepts custom message', () {
        const failure = NotFoundFailure('Product not found');
        expect(failure.message, 'Product not found');
      });
    });

    group('ValidationFailure', () {
      test('has default message', () {
        const failure = ValidationFailure();
        expect(failure.message, 'Validation failed');
      });

      test('accepts custom message', () {
        const failure = ValidationFailure('Name is required');
        expect(failure.message, 'Name is required');
      });
    });

    group('CacheFailure', () {
      test('has default message', () {
        const failure = CacheFailure();
        expect(failure.message, 'Cache error occurred');
      });
    });

    group('Failure inheritance', () {
      test('all failures extend Failure', () {
        expect(const ServerFailure(), isA<Failure>());
        expect(const NetworkFailure(), isA<Failure>());
        expect(const ClientFailure(), isA<Failure>());
        expect(const NotFoundFailure(), isA<Failure>());
        expect(const ValidationFailure(), isA<Failure>());
        expect(const CacheFailure(), isA<Failure>());
      });
    });
  });
}
