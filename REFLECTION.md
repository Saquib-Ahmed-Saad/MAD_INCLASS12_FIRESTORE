# Reflection - Inventory Management App with Firestore

## 1) What worked well in this project?

Using a clear layer split (domain, data, presentation) made the app easier to build and debug. Firestore streams with StreamBuilder gave instant UI updates after CRUD actions without manual refresh logic.

## 2) Biggest challenge and how it was solved

The biggest challenge was making sure validation prevents bad writes before reaching Firestore. I solved this by centralizing validation rules in a reusable validator class and connecting those rules to the form fields.

## 3) What I learned about real-time apps

Real-time apps require defensive UI states: loading, error, empty, and success. StreamBuilder simplifies this, but it is still important to check snapshot.hasError and handle waiting/empty states intentionally.

## 4) Two enhanced features added

- Search by item name and category.
- Low-stock-only filter with visual warning icon for low inventory.
- Bonus: visible item count and inventory value summary cards.

## 5) If I had more time

I would add authentication, category analytics charts, and export features (CSV/PDF) for reporting.
