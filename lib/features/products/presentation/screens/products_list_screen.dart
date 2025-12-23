import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/product.dart';
import '../cubits/product_list/product_list_cubit.dart';
import '../cubits/product_list/product_list_state.dart';
import '../widgets/error_view.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loading.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductsListScreen extends StatelessWidget {
  const ProductsListScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (_) => GetIt.I<ProductListCubit>()..fetchProducts(),
        child: const _ProductsListView(),
      );
}

class _ProductsListView extends StatefulWidget {
  const _ProductsListView();

  @override
  State<_ProductsListView> createState() => _ProductsListViewState();
}

class _ProductsListViewState extends State<_ProductsListView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductListCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _navigateToCreateProduct() async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductFormScreen(),
      ),
    );

    if (result != null && mounted) {
      context.read<ProductListCubit>().addProduct(result);
    }
  }

  void _navigateToDetail(Product product) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );

    if (mounted) {
      if (result == 'deleted') {
        context.read<ProductListCubit>().removeProduct(product.id);
      } else if (result is Product) {
        context.read<ProductListCubit>().updateProduct(result);
      }
    }
  }

  void _navigateToEdit(Product product) async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );

    if (result != null && mounted) {
      context.read<ProductListCubit>().updateProduct(result);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Titan Products'),
              Text(
                'Merchant Dashboard',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          toolbarHeight: 64,
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: () => context.read<ProductListCubit>().refresh(),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            BlocBuilder<ProductListCubit, ProductListState>(
              builder: (context, state) {
                if (state is ProductListLoaded) {
                  return _buildStatsBar(state);
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: BlocBuilder<ProductListCubit, ProductListState>(
                builder: (context, state) => switch (state) {
                  ProductListInitial() => const ProductsGridShimmer(),
                  ProductListLoading(isLoadingMore: false) => const ProductsGridShimmer(),
                  ProductListLoading(isLoadingMore: true, existingProducts: final products) =>
                    _buildProductsGrid(products, isLoadingMore: true),
                  ProductListLoaded(products: final products) when products.isEmpty => EmptyView(
                      message: 'No products yet.\nTap + to add your first product!',
                      icon: Icons.inventory_2_outlined,
                      onAction: _navigateToCreateProduct,
                      actionLabel: 'Add Product',
                    ),
                  ProductListLoaded(products: final products, meta: final meta) =>
                    _buildProductsGrid(products, canLoadMore: meta.hasMore),
                  ProductListError(message: final message, previousProducts: final products) when products.isEmpty =>
                    ErrorView(
                      message: message,
                      onRetry: () => context.read<ProductListCubit>().refresh(),
                    ),
                  ProductListError(message: final message, previousProducts: final products) =>
                    _buildProductsGridWithError(products, message),
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToCreateProduct,
          icon: const Icon(Icons.add),
          label: const Text('Add Product'),
        ),
      );

  Widget _buildSearchBar() => Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search products...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ProductListCubit>().search('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            setState(() {});
          },
          onSubmitted: (value) {
            context.read<ProductListCubit>().search(value);
          },
        ),
      );

  Widget _buildStatsBar(ProductListLoaded state) {
    final totalProducts = state.meta.total;
    final inStock = state.products.where((p) => p.inStock).length;
    final outOfStock = state.products.where((p) => !p.inStock).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          _buildStatChip(Icons.inventory, '$totalProducts products'),
          const SizedBox(width: 8),
          _buildStatChip(Icons.check_circle, '$inStock in stock', color: Colors.green),
          if (outOfStock > 0) ...[
            const SizedBox(width: 8),
            _buildStatChip(Icons.cancel, '$outOfStock out', color: Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, {Color? color}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: (color ?? Colors.grey).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );

  Widget _buildProductsGrid(
    List<Product> products, {
    bool isLoadingMore = false,
    bool canLoadMore = false,
  }) =>
      RefreshIndicator(
        onRefresh: () => context.read<ProductListCubit>().refresh(),
        child: GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length + (isLoadingMore ? 2 : 0),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              return const ProductCardShimmer();
            }

            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => _navigateToDetail(product),
              onEdit: () => _navigateToEdit(product),
            );
          },
        ),
      );

  Widget _buildProductsGridWithError(List<Product> products, String error) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.read<ProductListCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildProductsGrid(products),
          ),
        ],
      );
}
