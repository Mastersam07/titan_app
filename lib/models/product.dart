import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    this.stockQuantity = 0,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: _parsePrice(json['price']),
      imageUrl: json['image_url'] as String?,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      category: json['category'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final int stockQuantity;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'stock_quantity': stockQuantity,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stockQuantity,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Parses price from various formats
  static double _parsePrice(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Formatted price string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Check if in stock
  bool get inStock => stockQuantity > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        stockQuantity,
        category,
        createdAt,
        updatedAt,
      ];
}
