
# PrepPro Patch: Strict meal types + pretty shopping quantities

Copy these files into your existing project, replacing the originals:

- lib/core/services/plan_service.dart
- lib/features/plan/plan_page.dart
- lib/core/services/shopping_list_service.dart
- lib/features/shopping/shopping_list_page.dart

Then run:

```
flutter clean
flutter pub get
flutter analyze
```

**What changed**
- Breakfast/Snack/Lunch/Snack/Dinner are now STRICT per slot; no cross-over.
- Magic Replace keeps replacements within the same meal type.
- Shopping list normalizes units (g/kg, ml/L, pcs) and displays friendly quantities.
