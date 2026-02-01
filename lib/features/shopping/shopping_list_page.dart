import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/recipe_loader.dart';
import '../../core/services/plan_store.dart';
import '../../core/services/shopping_list_service.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});
  @override
  State<ShoppingListPage> createState() => _S();
}

class _S extends State<ShoppingListPage> {
  bool loading = true;
  List<ShoppingItem> items = [];
  final Map<String, bool> _checked = {};
  int missing = 0;
  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    setState(() => loading = true);
    final ids = await PlanStore.load();
    if (ids == null) {
      setState(() {
        loading = false;
        items = [];
        missing = 0;
      });
      return;
    }
    final all = await RecipeLoader.load();
    // flatten day entries to a single list of entries {id, servings}
    final flat = [for (final d in ids) ...d];
    final r = ShoppingListService.aggregate(allRecipes: all, selectedEntries: flat);
    setState(() {
      items = r.items;
      missing = r.missing;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Shopping List'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addCustomItem),
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: loading ? null : _build),
          IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: loading
                  ? null
                  : () async {
                      await PlanStore.clear();
                      if (!mounted) return;
                      setState(() {
                        items = [];
                        _checked.clear();
                        missing = 0;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved plan cleared.')));
                    })
        ],
      ),
      body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Transform.scale(
                  scale: 0.6,
                  child: Image.asset(
                    'assets/images/PrepProBlue.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ),
            loading
                ? const Center(child: CircularProgressIndicator())
                : (items.isEmpty
                    ? _empty(context, missing)
                    : _buildCategorizedList())
          ],
        ),
    );
  }

  Widget _buildCategorizedList() {
    // Group items by category
    final Map<String, List<ShoppingItem>> grouped = {};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    // Sort categories
    final categories = grouped.keys.toList()
      ..sort((a, b) {
        const order = ['Produce', 'Meat & Seafood', 'Dairy', 'Pantry', 'Spices & Herbs', 'Other'];
        final aIdx = order.contains(a) ? order.indexOf(a) : 999;
        final bIdx = order.contains(b) ? order.indexOf(b) : 999;
        return aIdx.compareTo(bIdx);
      });

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, catIndex) {
        final category = categories[catIndex];
        final categoryItems = grouped[category]!;
        final checkedCount = categoryItems.where((it) => _checked[it.name] == true).length;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$checkedCount/${categoryItems.length}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              ...categoryItems.map((item) => CheckboxListTile(
                    value: _checked[item.name] ?? false,
                    onChanged: (val) {
                      setState(() => _checked[item.name] = val ?? false);
                    },
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: _checked[item.name] == true
                            ? TextDecoration.lineThrough
                            : null,
                        color: _checked[item.name] == true
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : null,
                      ),
                    ),
                    subtitle: Text(
                      ShoppingListService.prettyQty(item.qty, item.unit),
                      style: TextStyle(
                        decoration: _checked[item.name] == true
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'produce':
        return Icons.eco;
      case 'meat & seafood':
      case 'meat':
        return Icons.set_meal;
      case 'dairy':
        return Icons.water_drop;
      case 'pantry':
        return Icons.kitchen;
      case 'spices & herbs':
      case 'spices':
        return Icons.grass;
      default:
        return Icons.shopping_basket;
    }
  }

  Future<void> _addCustomItem() async {
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    String selectedCategory = 'Other';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setModalState) => DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Produce', 'Meat & Seafood', 'Dairy', 'Pantry', 'Spices & Herbs', 'Other']
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  setModalState(() {
                    selectedCategory = val ?? 'Other';
                  });
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true && nameController.text.isNotEmpty) {
      final qty = double.tryParse(qtyController.text) ?? 1.0;
      setState(() {
        items.add(ShoppingItem(
          nameController.text,
          qty,
          '',
          selectedCategory,
        ));
      });
    }
  }

  Widget _empty(BuildContext context, int missing) {
    final msg = missing == 0
        ? 'No saved plan yet.\nGo to Plan and press Generate.'
        : 'No aggregatable ingredients found.\n${missing} recipe(s) had no ingredients list.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/plan'),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate a Plan'),
            ),
          ],
        ),
      ),
    );
  }
}
