import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/home_bottom_bar.dart';
import '../lectura.dart';
import '../oracion.dart';
import '../profile/profile_screen.dart';
import 'home.dart';

class TabShell extends StatefulWidget {
  final int initialIndex;

  const TabShell({super.key, this.initialIndex = 0});

  @override
  State<TabShell> createState() => _TabShellState();
}

class _TabShellState extends State<TabShell> {
  late int _selectedIndex;

  final List<Widget> _pages = const [
    HomeScreen(),
    LecturaScreen(),
    OracionScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onTabChanged(0);
          return;
        }
        SystemNavigator.pop();
      },
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: _pages[_selectedIndex],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: HomeBottomBar(
                selectedIndex: _selectedIndex,
                onTabChanged: _onTabChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
