# Titan Merchant App

[![CI](https://github.com/Mastersam07/titan_app/actions/workflows/ci.yml/badge.svg)](https://github.com/Mastersam07/titan_app/actions/workflows/ci.yml)
[![codecov](https://codecov.io/github/Mastersam07/titan_app/graph/badge.svg?token=mnHN6iIT1d)](https://codecov.io/github/Mastersam07/titan_app)

A Flutter merchant dashboard for managing products via the Titan Products API.

## Features

- **View Products**: Grid view with pull-to-refresh and infinite scroll
- **Create Products**: Add new products with name, price, description, category
- **Edit Products**: Update existing product details
- **Delete Products**: Remove products with confirmation
- **Search**: Real-time search by product name/description
- **Stats Dashboard**: Quick overview of total products and stock status

## Architecture

This app follows a **feature-first approach with hexagonal (clean) architecture** and Cubit for state management:

```
lib/
├── core/                                    # Shared core utilities
│   ├── error/
│   │   └── failures.dart                    # Failure types
│   ├── network/
│   │   └── api_constants.dart               # API configuration
│   └── usecases/
│       └── usecase.dart                     # Base use case interface
├── features/
│   └── products/                            # Products feature module
│       ├── data/                            # Data layer
│       │   ├── datasources/
│       │   │   └── product_remote_datasource.dart
│       │   ├── models/
│       │   │   └── product_model.dart
│       │   └── repositories/
│       │       └── product_repository_impl.dart
│       ├── domain/                          # Domain layer
│       │   ├── entities/
│       │   │   └── product.dart
│       │   ├── repositories/
│       │   │   └── product_repository.dart  # Abstract repository
│       │   └── usecases/
│       │       ├── get_products.dart
│       │       ├── get_product.dart
│       │       ├── create_product.dart
│       │       ├── update_product.dart
│       │       └── delete_product.dart
│       └── presentation/                    # Presentation layer
│           ├── cubits/
│           │   ├── product_list/
│           │   ├── product_detail/
│           │   ├── product_create/
│           │   └── product_edit/
│           ├── screens/
│           │   ├── products_list_screen.dart
│           │   ├── product_detail_screen.dart
│           │   └── product_form_screen.dart
│           └── widgets/
│               ├── product_card.dart
│               ├── shimmer_loading.dart
│               └── error_view.dart
├── injection.dart                           # Dependency injection setup
└── main.dart                                # Entry point
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Domain** | Business logic, entities, use cases, repository interfaces |
| **Data** | API calls, data models, repository implementations |
| **Presentation** | UI components, state management (Cubits), screens |

## Getting Started

### Prerequisites

- Flutter 3.0+ installed
- The Titan API running (see [titan-api](https://github.com/Mastersam07/titan_api))

### Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

### API Configuration

The app connects to a hosted API by default. To configure a different API URL, edit `lib/core/network/api_constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://titan-api-3f3i.onrender.com/api';

  // For local development:
  // static const String baseUrl = 'http://localhost:8000/api';

  // For Android emulator (local):
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
}
```

## Screens

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

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/cubits/product_list_cubit_test.dart

# Run flow tests only
flutter test test/flows/
```

### Test Structure

```
test/
├── flows/                          # Integration/Flow tests
│   └── product_flows_test.dart     # End-to-end user flow tests
├── helpers/
│   └── test_helpers.dart           # Mocks, fixtures, and test utilities
├── robots/                         # Robot pattern (Page Objects)
│   ├── product_list_robot.dart
│   ├── product_detail_robot.dart
│   └── product_form_robot.dart
└── unit/
    └── cubits/                     # Unit tests for Cubits
        ├── product_list_cubit_test.dart
        ├── product_detail_cubit_test.dart
        ├── product_create_cubit_test.dart
        └── product_edit_cubit_test.dart
```

### Test Types

| Type | Location | Description |
|------|----------|-------------|
| **Unit Tests** | `test/unit/cubits/` | Tests individual Cubits in isolation using `bloc_test` |
| **Flow Tests** | `test/flows/` | Widget tests covering complete user journeys |
| **Robots** | `test/robots/` | Page Object pattern classes for readable widget tests |

### Robot Pattern

The project uses the **Robot pattern** (Page Object pattern for Flutter) to make widget tests more readable and maintainable:

```dart
// Robot encapsulates UI interactions and assertions
class ProductListRobot {
  ProductListRobot(this.tester);
  final WidgetTester tester;

  // Finders
  Finder get productCards => find.byType(ProductCard);

  // Assertions
  Future<void> showsProducts(int count) async =>
    expect(productCards, findsNWidgets(count));

  // Actions
  Future<void> tapProduct(int index) async {
    await tester.tap(productCards.at(index));
    await tester.pumpAndSettle();
  }
}

// Usage in tests
testWidgets('shows products', (tester) async {
  await tester.pumpWidget(createTestApp(child: const ProductsListScreen()));
  final robot = ProductListRobot(tester);

  await robot.showsLoading();
  await tester.pumpAndSettle();
  await robot.showsProducts(2);
});
```

### Flow Tests Coverage

The flow tests cover complete user journeys:

1. **Product List Flows** - Load, empty state, error with retry, search, refresh
2. **Product Creation Flows** - Create successfully, validation errors
3. **Product Detail Flows** - View detail, delete product
4. **Product Edit Flows** - Edit from detail, edit from list
5. **Error Handling Flows** - API errors on create/edit/delete

## Dependencies

| Package | Purpose |
|---------|---------|
| flutter_bloc | State management (Cubit) |
| equatable | Value equality |
| dio | HTTP client |
| dartz | Functional programming (Either) |
| get_it | Dependency injection |
| cached_network_image | Image caching |
| shimmer | Loading effects |

### Dev Dependencies

| Package | Purpose |
|---------|---------|
| bloc_test | Testing Cubits |
| mocktail | Mocking for tests |

## State Management

The app uses **Cubit** with **sealed classes** for exhaustive pattern matching. Each feature operation has its own dedicated Cubit:

- `ProductListCubit` - Handles product list fetching, pagination, and search
- `ProductDetailCubit` - Handles single product fetch and deletion
- `ProductCreateCubit` - Handles product creation
- `ProductEditCubit` - Handles product updates

### Example State Pattern

```dart
// Sealed state classes (Dart 3)
sealed class ProductListState extends Equatable {}
final class ProductListInitial extends ProductListState {}
final class ProductListLoading extends ProductListState {}
final class ProductListLoaded extends ProductListState {}
final class ProductListError extends ProductListState {}

// Exhaustive pattern matching in UI
return switch (state) {
  ProductListInitial() => const ProductsGridShimmer(),
  ProductListLoading() => const ProductsGridShimmer(),
  ProductListLoaded(products: final products) => _buildProductsGrid(products),
  ProductListError() => ErrorView(...),
};
```

## API Integration

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

## Troubleshooting

### "Connection refused" error

1. Make sure the API is running and accessible
2. Check the URL in `lib/core/network/api_constants.dart`
3. For Android emulator with local API, use `10.0.2.2` instead of `localhost`

### Images not loading

The API uses picsum.photos for sample images. Make sure you have internet connectivity.

### Slow loading

Enable release mode for better performance:
```bash
flutter run --release
```
