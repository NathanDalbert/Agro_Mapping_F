// lib/ui/screens/main_navigation_screen.dart
import 'package:agromapping/ui/screens/cart_screen.dart';
import 'package:agromapping/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import 'feiras_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  // Lista de telas para navegar
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    FeirasScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Feiras',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('0'),
              child: Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Carrinho',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
