import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends ConsumerStatefulWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/transactions')) return 1;
    if (location.startsWith('/goals')) return 2;
    if (location.startsWith('/chat')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/goals');
        break;
      case 3:
        context.go('/chat');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.moneyBillTransfer),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.bullseye),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.robot),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
}
