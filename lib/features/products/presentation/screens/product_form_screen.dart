import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/product.dart';
import '../cubits/product_create/product_create_cubit.dart';
import '../cubits/product_create/product_create_state.dart';
import '../cubits/product_edit/product_edit_cubit.dart';
import '../cubits/product_edit/product_edit_state.dart';

class ProductFormScreen extends StatelessWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  bool get isEditing => product != null;

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return BlocProvider(
        create: (_) => GetIt.I<ProductEditCubit>()..setProduct(product!),
        child: _ProductEditForm(product: product!),
      );
    } else {
      return BlocProvider(
        create: (_) => GetIt.I<ProductCreateCubit>(),
        child: const _ProductCreateForm(),
      );
    }
  }
}

class _ProductCreateForm extends StatefulWidget {
  const _ProductCreateForm();

  @override
  State<_ProductCreateForm> createState() => _ProductCreateFormState();
}

class _ProductCreateFormState extends State<_ProductCreateForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;

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
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _priceController = TextEditingController();
    _imageUrlController = TextEditingController();
    _stockController = TextEditingController(text: '0');
    _categoryController = TextEditingController();
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

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProductCreateCubit>().create(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          stockQuantity: int.parse(_stockController.text),
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ProductCreateCubit, ProductCreateState>(
      listener: (context, state) {
        if (state is ProductCreateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, state.product);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProductCreateSubmitting;
        final errorMessage = state is ProductCreateError ? state.message : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('New Product'),
            actions: [
              if (isLoading)
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
          body: _buildForm(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onSave: _saveProduct,
            isEditing: false,
          ),
        );
      },
    );

  Widget _buildForm({
    required bool isLoading,
    required String? errorMessage,
    required VoidCallback onSave,
    required bool isEditing,
  }) => Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (errorMessage != null) ...[
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
                      errorMessage,
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
          DropdownButtonFormField<String>(
            initialValue: _categories.contains(_categoryController.text) ? _categoryController.text : null,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              )).toList(),
            onChanged: (value) {
              _categoryController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),
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
          FilledButton.icon(
            onPressed: isLoading ? null : onSave,
            icon: Icon(isEditing ? Icons.save : Icons.add),
            label: Text(isEditing ? 'Save Changes' : 'Create Product'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
}

class _ProductEditForm extends StatefulWidget {
  const _ProductEditForm({required this.product});

  final Product product;

  @override
  State<_ProductEditForm> createState() => _ProductEditFormState();
}

class _ProductEditFormState extends State<_ProductEditForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _stockController;
  late final TextEditingController _categoryController;

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
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(text: widget.product.description ?? '');
    _priceController = TextEditingController(
      text: widget.product.price.toStringAsFixed(2),
    );
    _imageUrlController = TextEditingController(text: widget.product.imageUrl ?? '');
    _stockController = TextEditingController(
      text: widget.product.stockQuantity.toString(),
    );
    _categoryController = TextEditingController(text: widget.product.category ?? '');
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

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProductEditCubit>().update(
          id: widget.product.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          stockQuantity: int.parse(_stockController.text),
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ProductEditCubit, ProductEditState>(
      listener: (context, state) {
        if (state is ProductEditSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, state.product);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProductEditSubmitting;
        final errorMessage = state is ProductEditError ? state.message : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Product'),
            actions: [
              if (isLoading)
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
          body: _buildForm(
            isLoading: isLoading,
            errorMessage: errorMessage,
            onSave: _saveProduct,
          ),
        );
      },
    );

  Widget _buildForm({
    required bool isLoading,
    required String? errorMessage,
    required VoidCallback onSave,
  }) => Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (errorMessage != null) ...[
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
                      errorMessage,
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
          DropdownButtonFormField<String>(
            initialValue: _categories.contains(_categoryController.text) ? _categoryController.text : null,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              )).toList(),
            onChanged: (value) {
              _categoryController.text = value ?? '';
            },
          ),
          const SizedBox(height: 16),
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
          FilledButton.icon(
            onPressed: isLoading ? null : onSave,
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
}
