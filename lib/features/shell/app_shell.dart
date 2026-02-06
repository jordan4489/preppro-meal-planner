import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/profile_service.dart';
import '../../core/models/profile.dart';
import '../../widgets/ad_banner.dart';

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  const _NavItem(this.route, this.icon, this.label);
}

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loc = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    return FutureBuilder<Profile?>(
      future: ProfileService.loadProfile(),
      builder: (context, snap) {
        final plannerOnly = snap.data?.plannerOnly ?? false;
        final tabs = <_NavItem>[
          const _NavItem('/home', Icons.home, 'Home'),
          const _NavItem('/recipes', Icons.menu_book, 'Recipes'),
          const _NavItem('/plan', Icons.calendar_month, 'Plan'),
          const _NavItem('/shopping', Icons.list_alt, 'Shopping'),
          if (!plannerOnly) const _NavItem('/weight', Icons.monitor_weight, 'Weight'),
        ];
        var currentIndex = tabs.indexWhere((t) => loc.startsWith(t.route));
        if (currentIndex < 0) currentIndex = 0;

        return Scaffold(
          body: child,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AdBanner(),
              BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (i) => context.go(tabs[i].route),
                items: tabs
                    .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
                    .toList(),
                type: BottomNavigationBarType.fixed,
              ),
            ],
          ),
        );
      },
    );
  }
}
