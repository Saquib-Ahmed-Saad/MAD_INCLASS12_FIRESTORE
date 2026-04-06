# Inventory Management App with Firestore

Real-time Flutter inventory app that performs CRUD operations on Cloud Firestore and keeps UI synchronized using streams.

## Assignment Coverage

- Firebase connected in main with Firebase.initializeApp.
- Inventory model includes toMap and fromMap.
- Firestore service supports add, stream, update, and delete.
- UI uses StreamBuilder with ListView.builder.
- Form validation covers empty fields, numeric parsing, and invalid values.
- Enhanced features documented below.

## Tech Stack

- Flutter and Dart
- firebase_core
- cloud_firestore

## Architecture (Clean Layers)

- Domain
	- Inventory entity
	- Repository contract
- Data
	- Firestore service for direct cloud operations
	- Repository implementation that maps models to domain entities
	- InventoryItemModel with fromMap and toMap
- Presentation
	- InventoryPage with StreamBuilder and CRUD UI
	- Form dialog with validator-based input checks

Source layout used in this project:

```text
lib/
	main.dart
	src/
		app.dart
		core/
			validators/
		features/
			inventory/
				domain/
					entities/
					repositories/
				data/
					models/
					services/
					repositories/
				presentation/
					pages/
```

## Firestore Data Shape

Collection: inventory_items

Each document:

```json
{
	"name": "Wireless Mouse",
	"category": "Electronics",
	"quantity": 10,
	"price": 24.99,
	"updatedAt": "Timestamp"
}
```

## Features

Core CRUD:
- Add item
- Read item stream in real time
- Update item
- Delete item with confirmation

Validation:
- Required name validation
- Quantity must be numeric whole number and non-negative
- Price must be numeric and greater than 0

Enhanced Features:
- Live search by item name or category
- Low-stock filter toggle (quantity <= 5)
- Summary cards for visible item count and visible inventory value

## Setup Instructions

1. Clone this repository.
2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase for this app (required once per platform):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Enable Cloud Firestore in Firebase Console (test mode for development).
5. Run the app:

```bash
flutter run
```

## Build APK

```bash
flutter build apk --release
```

Generated file:

build/app/outputs/flutter-apk/app-release.apk

## Testing and Verification

Run static checks and tests:

```bash
flutter analyze
flutter test
```

Included tests:
- Validator tests for required, numeric, and invalid inputs
- Model mapping test for toMap and fromMap
- Existing habit metrics tests retained from previous module

## Reflection

See REFLECTION.md for the required reflection answers document.

## Submission Checklist

- Public GitHub repository URL
- New commit history for this assignment only
- README with enhanced features listed
- APK artifact included
- Reflection document included
