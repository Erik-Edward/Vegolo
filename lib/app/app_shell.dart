import 'package:flutter/material.dart';
import 'package:vegolo/features/history/presentation/pages/history_page.dart';
import 'package:vegolo/features/scanning/presentation/pages/scanning_page.dart';
import 'package:vegolo/features/settings/presentation/pages/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  // Separate Navigator for each tab to preserve state.
  final _navKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Future<bool> _onWillPop() async {
    final navigator = _navKeys[_index].currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return false;
    }
    return true;
  }

  void _onTap(int newIndex) {
    if (newIndex == _index) {
      // Pop to first route on reselect
      final nav = _navKeys[newIndex].currentState;
      nav?.popUntil((route) => route.isFirst);
    } else {
      setState(() => _index = newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            _TabNavigator(key: _navKeys[0], child: const ScanningPage()),
            _TabNavigator(key: _navKeys[1], child: const HistoryPage()),
            _TabNavigator(key: _navKeys[2], child: const SettingsPage()),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.center_focus_strong_outlined),
              selectedIcon: Icon(Icons.center_focus_strong),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          onDestinationSelected: _onTap,
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  const _TabNavigator({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => child,
      ),
    );
  }
}

