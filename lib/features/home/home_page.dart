import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/progress_card.dart';
import '../../core/services/profile_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _openTab(BuildContext context, String tab) {
    switch (tab) {
      case 'plan':
        context.go('/plan');
        break;
      case 'recipes':
        context.go('/recipes');
        break;
      case 'shopping':
        context.go('/shopping');
        break;
      default:
        context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tiles = <_HomeTile>[
      _HomeTile(
          title: 'Plan',
          icon: Icons.calendar_month,
          color: cs.primaryContainer,
          onTap: () => _openTab(context, 'plan')),
      _HomeTile(
          title: 'Recipes',
          icon: Icons.menu_book,
          color: cs.secondaryContainer,
          onTap: () => _openTab(context, 'recipes')),
      _HomeTile(
          title: 'Shopping list',
          icon: Icons.list_alt,
          color: cs.tertiaryContainer,
          onTap: () => _openTab(context, 'shopping')),
      _HomeTile(
          title: 'Weight tracker',
          icon: Icons.monitor_weight,
          color: cs.surfaceContainerHighest,
          onTap: () => context.go('/weight')),
    ];

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        centerTitle: true,
        title: Image.asset('assets/images/logo_preppro_blue.png', height: 42, errorBuilder: (_, __, ___) => const Text('PrepPro')),
        actions: [
          IconButton(onPressed: () => context.go('/profile'), icon: const Icon(Icons.person), tooltip: 'Profile'),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
      ),
      body: Stack(
        children: [
          // Full background logo watermark
          Positioned.fill(
            child: Opacity(
              opacity: 0.035,
              child: Image.asset(
                'assets/images/logo_preppro_blue.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          // Main content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
          // Welcome guidance banner
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).colorScheme.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rocket_launch,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Start Guide',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Set profile → Generate plan → Start cooking!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<int?>(
            future: ProfileService.computeDailyTarget(),
            builder: (c, snap) {
              final t = snap.data;
              final subtitle = t == null ? 'Tap to set your goal' : 'Target: $t kcal';
              final progress = 0.0; // TODO: hook up actual consumed calories
              return Column(children: [
                ProgressCard(title: 'Calories', subtitle: subtitle, progress: progress, onTap: () async {
                  // navigate to Profile for edits
                  context.go('/profile');
                  setState(() {});
                }),
                const SizedBox(height: 24),
          FutureBuilder<int>(
            future: ProfileService.getWeeklyPlanCount(),
            builder: (c, snap) {
              final count = snap.data ?? 0;
              final progress = count / 7.0;
              return ProgressCard(
                title: 'Weekly Activity',
                subtitle: '$count of 7 days with meal plans',
                progress: progress.clamp(0.0, 1.0),
                onTap: () => context.go('/plan'),
              );
            },
          ),
              ]);
            },
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Quick actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _openTab(context, 'plan'),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Plan', style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _openTab(context, 'recipes'),
                icon: const Icon(Icons.search, size: 20),
                label: const Text('Recipes', style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _openTab(context, 'shopping'),
                icon: const Icon(Icons.list, size: 20),
                label: const Text('Shop', style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse features and start planning your meals',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List>(future: null, builder: (ctx, snap) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // Responsive grid: 2 columns on mobile, 3+ on wider screens
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                final childAspectRatio = constraints.maxWidth > 600 ? 1.1 : 1.0;
                return GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                  children: tiles.map((t) => _TileCard(tile: t)).toList(),
                );
              },
            );
          })
            ]),
          ),
        ],
      ),
    );
  }
}

class _HomeTile {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  _HomeTile(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});
}

class _TileCard extends StatelessWidget {
  final _HomeTile tile;
  const _TileCard({required this.tile});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: tile.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: tile.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tile.icon, size: 40),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    tile.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
