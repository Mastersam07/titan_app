import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/products/products_cubit.dart';
import '../../data/repositories/product_repository.dart';
import '../../models/product.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// If provided, we're editing. Otherwise, creating new.
  final Product? product;

  bool get isEditing => product != null;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = ProductRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Electronics',
    'Furniture',
    'Accessories',
    'Clothing',
    'Food',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(
      text: widget.product?.price.toStringAsFixed(2) ?? '',
    );
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _stockController = TextEditingController(
      text: widget.product?.stockQuantity.toString() ?? '0',
    );
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'price': double.parse(_priceController.text),
        'image_url': _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        'stock_quantity': int.parse(_stockController.text),
        'category': _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
      };

      if (widget.isEditing) {
        // Update existing product
        final result = await _repository.updateProduct(
          widget.product!.id,
          productData,
        );

        result.fold(
          (failure) {
            setState(() {
              _errorMessage = failure.message;
              _isLoading = false;
            });
          },
          (updatedProduct) {
            // Update in cubit if available
            if (mounted) {
              try {
                context.read<ProductsCubit>().updateProduct(updatedProduct);
              } catch (_) {}

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, updatedProduct);
            }
          },
        );
      } else {
        // Create new product
        final newProduct = Product(
          id: 0,
          name: productData['name'] as String,
          description: productData['description'] as String?,
          price: productData['price'] as double,
          imageUrl: productData['image_url'] as String?,
          stockQuantity: productData['stock_quantity'] as int,
          category: productData['category'] as String?,
        );

        final result = await _repository.createProduct(newProduct);

        result.fold(
          (failure) {
            setState(() {
              _errorMessage = failure.message;
              _isLoading = false;
            });
          },
          (createdProduct) {
            // Add to cubit if available
            if (mounted) {
              try {
                context.read<ProductsCubit>().addProduct(createdProduct);
              } catch (_) {}

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product created successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context, createdProduct);
            }
          },
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Product' : 'New Product'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name *',
                hintText: 'Enter product name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Product name is required';
                }
                if (value.trim().length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Price field
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price *',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Enter a valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stock field
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock Quantity',
                hintText: '0',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.warehouse_outlined),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final stock = int.tryParse(value);
                  if (stock == null || stock < 0) {
                    return 'Enter a valid quantity';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              initialValue: _categories.contains(_categoryController.text) ? _categoryController.text : null,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                _categoryController.text = value ?? '';
              },
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter product description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Image URL field
            TextFormField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image_outlined),
              ),
              keyboardType: TextInputType.url,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme) {
                    return 'Enter a valid URL';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _isLoading ? null : _saveProduct,
              icon: Icon(widget.isEditing ? Icons.save : Icons.add),
              label: Text(widget.isEditing ? 'Save Changes' : 'Create Product'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
