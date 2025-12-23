import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/models/api_response.dart';

void main() {
  group('PaginationMeta', () {
    test('fromJson creates meta correctly', () {
      final json = {'total': 100, 'limit': 20, 'offset': 40};
      final meta = PaginationMeta.fromJson(json);

      expect(meta.total, 100);
      expect(meta.limit, 20);
      expect(meta.offset, 40);
    });

    test('fromJson handles missing values with defaults', () {
      final meta = PaginationMeta.fromJson({});

      expect(meta.total, 0);
      expect(meta.limit, 100);
      expect(meta.offset, 0);
    });

    test('hasMore returns true when more items available', () {
      final meta = PaginationMeta.fromJson({
        'total': 100,
        'limit': 20,
        'offset': 0,
      });

      expect(meta.hasMore, true);
    });

    test('hasMore returns false when at end', () {
      final meta = PaginationMeta.fromJson({
        'total': 100,
        'limit': 20,
        'offset': 80,
      });

      expect(meta.hasMore, false);
    });

    test('hasMore returns false when exactly at end', () {
      final meta = PaginationMeta.fromJson({
        'total': 100,
        'limit': 20,
        'offset': 100,
      });

      expect(meta.hasMore, false);
    });

    test('nextOffset calculates correctly', () {
      final meta = PaginationMeta.fromJson({
        'total': 100,
        'limit': 20,
        'offset': 40,
      });

      expect(meta.nextOffset, 60);
    });
  });

  group('ProductsResponse', () {
    test('fromJson creates response correctly', () {
      final json = {
        'success': true,
        'data': [
          {'id': 1, 'name': 'Product 1', 'price': 99.99},
          {'id': 2, 'name': 'Product 2', 'price': 149.99},
        ],
        'meta': {'total': 2, 'limit': 20, 'offset': 0},
      };

      final response = ProductsResponse.fromJson(json);

      expect(response.success, true);
      expect(response.products.length, 2);
      expect(response.products[0].name, 'Product 1');
      expect(response.meta.total, 2);
    });

    test('fromJson handles empty data', () {
      final json = {
        'success': true,
        'data': [],
        'meta': {'total': 0, 'limit': 20, 'offset': 0},
      };

      final response = ProductsResponse.fromJson(json);

      expect(response.products, isEmpty);
    });

    test('fromJson handles missing data', () {
      final json = {'success': false};

      final response = ProductsResponse.fromJson(json);

      expect(response.success, false);
      expect(response.products, isEmpty);
    });
  });

  group('ProductResponse', () {
    test('fromJson creates response correctly', () {
      final json = {
        'success': true,
        'message': 'Product created',
        'data': {'id': 1, 'name': 'New Product', 'price': 99.99},
      };

      final response = ProductResponse.fromJson(json);

      expect(response.success, true);
      expect(response.message, 'Product created');
      expect(response.product.id, 1);
      expect(response.product.name, 'New Product');
    });

    test('fromJson handles missing message', () {
      final json = {
        'success': true,
        'data': {'id': 1, 'name': 'Product', 'price': 99.99},
      };

      final response = ProductResponse.fromJson(json);

      expect(response.message, isNull);
    });
  });

  group('ErrorResponse', () {
    test('fromJson creates error response correctly', () {
      final json = {
        'success': false,
        'error': {
          'code': 404,
          'message': 'Product not found',
        },
      };

      final response = ErrorResponse.fromJson(json);

      expect(response.success, false);
      expect(response.code, 404);
      expect(response.message, 'Product not found');
    });

    test('fromJson handles missing error details', () {
      final json = {'success': false};

      final response = ErrorResponse.fromJson(json);

      expect(response.code, 0);
      expect(response.message, 'Unknown error');
    });
  });
}
