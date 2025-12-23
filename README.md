# Titan Merchant App

A Flutter merchant dashboard for managing products via the Titan Products API.

## 🛒 Features

- **View Products**: Grid view with pull-to-refresh and infinite scroll
- **Create Products**: Add new products with name, price, description, category
- **Edit Products**: Update existing product details
- **Delete Products**: Remove products with confirmation
- **Search**: Real-time search by product name/description
- **Stats Dashboard**: Quick overview of total products and stock status

## 🏗️ Architecture

This app follows a clean architecture pattern with Cubit for state management:

```
lib/
├── core/                    # Core utilities
│   ├── api_constants.dart   # API configuration
│   └── failures.dart        # Failure types
├── models/                  # Data models
│   ├── product.dart
│   └── api_response.dart
├── data/
│   ├── providers/           # API calls (Dio)
│   │   └── api_provider.dart
│   └── repositories/        # Data access layer
│       └── product_repository.dart
├── cubits/                  # State management
│   └── products/
│       ├── products_cubit.dart
│       └── products_state.dart   # Sealed classes
├── ui/
│   ├── screens/
│   │   ├── products_list_screen.dart   # Main dashboard
│   │   ├── product_detail_screen.dart  # View/Edit/Delete
│   │   └── product_form_screen.dart    # Create/Edit form
│   └── widgets/
│       ├── product_card.dart
│       ├── shimmer_loading.dart
│       └── error_view.dart
├── injection.dart           # Dependency injection
└── main.dart                # Entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.0+ installed
- The PHP API running (see titan-api README)

### Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Configure API URL

Edit `lib/core/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'http://localhost:8000';
  
  // For Android emulator:
  // static const String baseUrl = 'http://10.0.2.2:8000';
  
  // For physical device (use your machine's IP):
  // static const String baseUrl = 'http://192.168.1.100:8000';
  
  // For ngrok tunnel:
  // static const String baseUrl = 'https://abc123.ngrok.io';
}
```

## 📱 Screens

### Products List (Dashboard)
- Grid view of all products
- Stats bar showing total products, in-stock, out-of-stock counts
- Search bar with real-time filtering
- Pull-to-refresh
- Infinite scroll pagination
- FAB to add new product
- Edit button on each product card

### Product Detail
- Full product information
- Edit and Delete actions in app bar
- Stock status indicator
- Product metadata (ID, dates, etc.)

### Product Form
- Create new products
- Edit existing products
- Form validation
- Category dropdown
- Image URL preview

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management (Cubit) |
| equatable | Value equality |
| dio | HTTP client |
| dartz | Functional programming (Either) |
| get_it | Dependency injection |
| cached_network_image | Image caching |
| shimmer | Loading effects |

## 🔧 State Management

The app uses **Cubit** with **sealed classes** for exhaustive pattern matching:

```dart
// Sealed state classes (Dart 3)
sealed class ProductsState extends Equatable {}
final class ProductsInitial extends ProductsState {}
final class ProductsLoading extends ProductsState {}
final class ProductsLoaded extends ProductsState {}
final class ProductsError extends ProductsState {}

// Exhaustive pattern matching in UI
return switch (state) {
  ProductsInitial() => const ProductsGridShimmer(),
  ProductsLoading(isLoadingMore: false) => const ProductsGridShimmer(),
  ProductsLoading(isLoadingMore: true, existingProducts: final products) => 
    _buildProductsGrid(products, isLoadingMore: true),
  ProductsLoaded(products: []) => EmptyView(...),
  ProductsLoaded(products: final products) => _buildProductsGrid(products),
  ProductsError(previousProducts: []) => ErrorView(...),
  ProductsError(previousProducts: final products) => _buildWithError(products),
};
```

### Cubit Actions
```dart
fetchProducts()     // Initial load
loadMore()          // Pagination
search(query)       // Search products
refresh()           // Pull to refresh
deleteProduct(id)   // Remove product
addProduct(p)       // Add after create
updateProduct(p)    // Update after edit
```

## 📡 API Integration

The app connects to the Titan Products API with full CRUD support:

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/products` | List products (pagination, search, filter) |
| GET | `/products/{id}` | Get single product |
| POST | `/products` | Create new product |
| PUT | `/products/{id}` | Update product |
| DELETE | `/products/{id}` | Delete product |

### Create Product Request
```json
{
  "name": "New Product",
  "description": "Product description",
  "price": 29.99,
  "stock_quantity": 100,
  "category": "Electronics",
  "image_url": "https://example.com/image.jpg"
}
```

## 🎨 UI Components

### ProductCard
Displays product in grid with:
- Cached network image
- Category badge
- Price
- Stock status

### ProductDetailScreen
Full product view with:
- Hero image
- Description
- Stock information
- Add to cart button

### Loading States
- Shimmer effect for grid items
- Pull-to-refresh indicator
- Pagination loading indicator

## 📋 Troubleshooting

### "Connection refused" error

1. Make sure the PHP API is running
2. Check the URL in `api_constants.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`

### Images not loading

The API uses picsum.photos for sample images. Make sure you have internet connectivity.

### Slow loading

Enable release mode for better performance:
```bash
flutter run --release
```