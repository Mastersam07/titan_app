import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/product.dart';
import '../cubits/product_detail/product_detail_cubit.dart';
import '../cubits/product_detail/product_detail_state.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.I<ProductDetailCubit>()..loadProduct(productId),
        child: const _ProductDetailView(),
      );
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  Future<void> _editProduct(BuildContext context, Product product) async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );

    if (result != null && context.mounted) {
      context.read<ProductDetailCubit>().updateProduct(result);
    }
  }

  Future<void> _deleteProduct(BuildContext context, Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final cubit = context.read<ProductDetailCubit>();
      final success = await cubit.delete();

      if (context.mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete product'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<ProductDetailCubit, ProductDetailState>(
        listener: (context, state) {
          if (state is ProductDetailDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, 'deleted');
          }
        },
        builder: (context, state) => switch (state) {
          ProductDetailInitial() || ProductDetailLoading() => Scaffold(
              appBar: AppBar(),
              body: const Center(child: CircularProgressIndicator()),
            ),
          ProductDetailError(message: final message, product: null) => Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            ),
          ProductDetailLoaded(product: final product) ||
          ProductDetailDeleting(product: final product) ||
          ProductDetailError(product: final product?) =>
            Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 300,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildImage(product),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit Product',
                        onPressed: () => _editProduct(context, product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete Product',
                        onPressed: () => _deleteProduct(context, product),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (product.category case final category?) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ID: ${product.id}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.formattedPrice,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          _buildStockStatus(context, product),
                          const SizedBox(height: 24),
                          if (product.description case final description? when description.isNotEmpty) ...[
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                            ),
                            const SizedBox(height: 24),
                          ],
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Product Details',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildDetailRow(context, 'Product ID', '#${product.id}'),
                                  _buildDetailRow(context, 'Stock Quantity', '${product.stockQuantity} units'),
                                  _buildDetailRow(context, 'Category', product.category ?? 'Uncategorized'),
                                  if (product.imageUrl case final imageUrl?)
                                    _buildDetailRow(context, 'Image URL', imageUrl, isUrl: true),
                                  if (product.createdAt case final createdAt?)
                                    _buildDetailRow(context, 'Created', _formatDate(createdAt)),
                                  if (product.updatedAt case final updatedAt?)
                                    _buildDetailRow(context, 'Last Updated', _formatDate(updatedAt)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _editProduct(context, product),
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Edit Product'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _deleteProduct(context, product),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    foregroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ProductDetailDeleted() => const SizedBox.shrink(),
        },
      );

  Widget _buildImage(Product product) => switch (product.imageUrl) {
        final imageUrl? when imageUrl.isNotEmpty => CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.grey),
              ),
            ),
          ),
        _ => Container(
            color: Colors.grey[200],
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 64, color: Colors.grey),
            ),
          ),
      };

  Widget _buildStockStatus(BuildContext context, Product product) {
    final (bgColor, borderColor, fgColor, icon, text) = product.inStock
        ? (
            Colors.green[50],
            Colors.green[200],
            Colors.green[700],
            Icons.check_circle,
            '${product.stockQuantity} in stock'
          )
        : (Colors.red[50], Colors.red[200], Colors.red[700], Icons.cancel, 'Out of stock');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? Colors.grey),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontWeight: FontWeight.w500, color: fgColor)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isUrl = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isUrl ? Theme.of(context).colorScheme.primary : null,
                ),
                maxLines: isUrl ? 1 : null,
                overflow: isUrl ? TextOverflow.ellipsis : null,
              ),
            ),
          ],
        ),
      );

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
