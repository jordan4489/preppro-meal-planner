import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexFromLocation(String loc) {
    if (loc.startsWith('/recipes')) return 1;
    if (loc.startsWith('/plan')) return 2;
    if (loc.startsWith('/shopping')) return 3;
    if (loc.startsWith('/weight')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
    final idx = _indexFromLocation(loc);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).go('/plan'),
        tooltip: 'Quick add',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/recipes');
              break;
            case 2:
              context.go('/plan');
              break;
            case 3:
              context.go('/shopping');
              break;
            case 4:
              context.go('/weight');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Recipes'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Shopping'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_weight), label: 'Weight'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
