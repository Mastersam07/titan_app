import 'package:flutter_test/flutter_test.dart';
import 'package:titan_flutter/models/product.dart';

void main() {
  group('Product', () {
    const testJson = {
      'id': 1,
      'name': 'Test Product',
      'description': 'A test product',
      'price': 99.99,
      'image_url': 'https://example.com/image.jpg',
      'stock_quantity': 10,
      'category': 'Electronics',
      'created_at': '2024-01-15T10:30:00Z',
      'updated_at': '2024-01-15T10:30:00Z',
    };

    test('fromJson creates Product correctly', () {
      final product = Product.fromJson(testJson);

      expect(product.id, 1);
      expect(product.name, 'Test Product');
      expect(product.description, 'A test product');
      expect(product.price, 99.99);
      expect(product.imageUrl, 'https://example.com/image.jpg');
      expect(product.stockQuantity, 10);
      expect(product.category, 'Electronics');
    });

    test('fromJson handles string price', () {
      final json = {...testJson, 'price': '49.99'};
      final product = Product.fromJson(json);

      expect(product.price, 49.99);
    });

    test('fromJson handles int price', () {
      final json = {...testJson, 'price': 50};
      final product = Product.fromJson(json);

      expect(product.price, 50.0);
    });

    test('toJson returns correct map', () {
      final product = Product.fromJson(testJson);
      final json = product.toJson();

      expect(json['id'], 1);
      expect(json['name'], 'Test Product');
      expect(json['price'], 99.99);
    });

    test('formattedPrice returns correct format', () {
      final product = Product.fromJson(testJson);

      expect(product.formattedPrice, '\$99.99');
    });

    test('inStock returns true when stock > 0', () {
      final product = Product.fromJson(testJson);

      expect(product.inStock, true);
    });

    test('inStock returns false when stock is 0', () {
      final json = {...testJson, 'stock_quantity': 0};
      final product = Product.fromJson(json);

      expect(product.inStock, false);
    });

    test('copyWith creates new instance with updated values', () {
      final product = Product.fromJson(testJson);
      final updated = product.copyWith(name: 'Updated Name', price: 199.99);

      expect(updated.name, 'Updated Name');
      expect(updated.price, 199.99);
      expect(updated.id, product.id);
      expect(updated.description, product.description);
    });

    test('equality works correctly', () {
      final product1 = Product.fromJson(testJson);
      final product2 = Product.fromJson(testJson);

      expect(product1, product2);
    });
  });
}
