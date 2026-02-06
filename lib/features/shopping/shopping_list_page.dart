import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
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
  bool _budgetEnabled = false;
  double? _budgetAmount;
  double _estimatedTotal = 0.0;
  @override
  void initState() {
    super.initState();
    _loadBudget();
    _build();
  }

  Future<void> _loadBudget() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _budgetEnabled = sp.getBool('pp_budget_enabled_v1') ?? false;
      final v = sp.getDouble('pp_budget_amount_v1');
      _budgetAmount = v;
    });
  }

  Future<void> _saveBudget() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('pp_budget_enabled_v1', _budgetEnabled);
    if (_budgetAmount != null) {
      await sp.setDouble('pp_budget_amount_v1', _budgetAmount!);
    }
  }

  void _recalcEstimate() {
    _estimatedTotal = _estimateCost(items);
  }

  NumberFormat _currencyFormat(BuildContext context) {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    final localeWithCountry = locales.firstWhere(
      (l) => (l.countryCode ?? '').isNotEmpty,
      orElse: () => Localizations.localeOf(context),
    );
    final country = (localeWithCountry.countryCode ?? '').toUpperCase();
    final currency = _currencyCodeForCountry(country);
    final localeTag = localeWithCountry.toLanguageTag();
    return NumberFormat.simpleCurrency(locale: localeTag, name: currency);
  }

  String? _currencyCodeForCountry(String country) {
    switch (country) {
      case 'GB':
        return 'GBP';
      case 'US':
        return 'USD';
      case 'CA':
        return 'CAD';
      case 'AU':
        return 'AUD';
      case 'NZ':
        return 'NZD';
      case 'IE':
      case 'DE':
      case 'FR':
      case 'ES':
      case 'IT':
      case 'NL':
      case 'BE':
      case 'PT':
      case 'FI':
      case 'AT':
      case 'GR':
      case 'LU':
      case 'SI':
      case 'SK':
      case 'EE':
      case 'LV':
      case 'LT':
      case 'MT':
      case 'CY':
        return 'EUR';
      default:
        return null;
    }
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
      _recalcEstimate();
    });
  }

  Future<void> _exportList() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to export.')),
      );
      return;
    }
    final grouped = <String, List<ShoppingItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    final categories = grouped.keys.toList()
      ..sort((a, b) {
        const order = ['Produce', 'Meat & Seafood', 'Dairy', 'Pantry', 'Spices & Herbs', 'Other'];
        final aIdx = order.contains(a) ? order.indexOf(a) : 999;
        final bIdx = order.contains(b) ? order.indexOf(b) : 999;
        return aIdx.compareTo(bIdx);
      });

    final buffer = StringBuffer();
    buffer.writeln('PrepPro Shopping List');
    buffer.writeln('');
    for (final cat in categories) {
      buffer.writeln(cat.toUpperCase());
      for (final item in grouped[cat]!) {
        buffer.writeln('- ${item.name} • ${ShoppingListService.prettyQty(item.qty, item.unit)}');
      }
      buffer.writeln('');
    }

    await Share.share(buffer.toString(), subject: 'PrepPro Shopping List');
  }

  Future<void> _editBudget() async {
    final fmt = _currencyFormat(context);
    final controller = TextEditingController(text: _budgetAmount?.toStringAsFixed(2) ?? '');
    bool enabled = _budgetEnabled;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Budget mode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable weekly budget'),
              value: enabled,
              onChanged: (v) => setState(() => enabled = v),
            ),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Budget amount (${fmt.currencyName ?? fmt.currencySymbol})')
                  .copyWith(prefixText: '${fmt.currencySymbol} '),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok == true) {
      final v = double.tryParse(controller.text);
      setState(() {
        _budgetEnabled = enabled;
        _budgetAmount = v;
      });
      await _saveBudget();
    }
  }

  double _estimateCost(List<ShoppingItem> list) {
    const perKg = <String, double>{
      'chicken breast': 7.0,
      'chicken thighs': 5.0,
      'beef mince': 8.0,
      'turkey mince': 7.5,
      'salmon': 14.0,
      'prawns': 16.0,
      'rice': 2.0,
      'pasta': 2.2,
      'quinoa': 4.0,
      'potato': 1.2,
      'onion': 1.2,
      'pepper': 3.0,
      'broccoli': 2.4,
      'tomato': 2.0,
      'mushroom': 3.0,
    };
    const perL = <String, double>{
      'milk': 1.2,
      'cream': 2.2,
    };
    const perPc = <String, double>{
      'egg': 0.25,
      'lemon': 0.5,
      'lime': 0.5,
    };

    double total = 0;
    for (final item in list) {
      final name = item.name.toLowerCase();
      double? unitPrice;
      if (item.unit == 'g' || item.unit == 'kg') {
        final match = perKg.entries.firstWhere(
          (e) => name.contains(e.key),
          orElse: () => const MapEntry('', 0),
        );
        unitPrice = match.key.isEmpty ? null : match.value;
        final qtyKg = item.unit == 'kg' ? item.qty : item.qty / 1000.0;
        if (unitPrice != null) total += qtyKg * unitPrice;
      } else if (item.unit == 'ml' || item.unit == 'l') {
        final match = perL.entries.firstWhere(
          (e) => name.contains(e.key),
          orElse: () => const MapEntry('', 0),
        );
        unitPrice = match.key.isEmpty ? null : match.value;
        final qtyL = item.unit == 'l' ? item.qty : item.qty / 1000.0;
        if (unitPrice != null) total += qtyL * unitPrice;
      } else if (item.unit == 'pc') {
        final match = perPc.entries.firstWhere(
          (e) => name.contains(e.key),
          orElse: () => const MapEntry('', 0),
        );
        unitPrice = match.key.isEmpty ? null : match.value;
        if (unitPrice != null) total += item.qty * unitPrice;
      }
    }
    return total;
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
              icon: const Icon(Icons.price_change),
              onPressed: _editBudget,
              tooltip: 'Budget mode'),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportList,
            tooltip: 'Export list'),
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
      body: SafeArea(
        child: Stack(
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
            Positioned.fill(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : (items.isEmpty
                      ? _empty(context, missing)
                      : _buildCategorizedList()),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCategorizedList() {
    final fmt = _currencyFormat(context);
    final swaps = _smartSwaps();

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

    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text('Estimated total: ${fmt.format(_estimatedTotal)}'),
            subtitle: _budgetEnabled && _budgetAmount != null
              ? Text('Budget: ${fmt.format(_budgetAmount!)} • Remaining: ${fmt.format(_budgetAmount! - _estimatedTotal)}')
                : const Text('Set a weekly budget to track spending'),
          ),
        ),
        if (swaps.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: const Icon(Icons.lightbulb_outline),
              title: const Text('Smart swaps'),
              subtitle: const Text('Save money with simple substitutions'),
              children: [
                for (final s in swaps)
                  ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: Text(s),
                  ),
              ],
            ),
          ),
        for (final category in categories)
          _buildCategoryCard(context, category, grouped[category]!),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, List<ShoppingItem> categoryItems) {
    final checkedCount = categoryItems.where((it) => _checked[it.name] == true).length;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
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
  }

  List<String> _smartSwaps() {
    const swapMap = <String, String>{
      'sour cream': 'greek yogurt',
      'cream': 'evaporated milk',
      'butter': 'olive oil',
      'white sugar': 'honey',
      'brown sugar': 'coconut sugar',
      'milk': 'oat milk',
      'beef mince': 'turkey mince',
      'chicken breast': 'chicken thighs',
      'rice': 'quinoa',
      'pasta': 'wholewheat pasta',
      'breadcrumbs': 'crushed oats',
      'parmesan': 'nutritional yeast',
    };

    final names = items.map((e) => e.name.toLowerCase()).toList();
    final out = <String>{};
    for (final entry in swapMap.entries) {
      final key = entry.key;
      if (names.any((n) => n.contains(key))) {
        out.add('Swap ${entry.key} → ${entry.value}');
      }
    }
    return out.toList();
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
                initialValue: selectedCategory,
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
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
        ),
      ),
    );
  }
}
