import 'package:agromapping/ui/screens/cart_screen.dart';
import 'package:agromapping/ui/screens/dashboard_vendedor_screen.dart';
import 'package:agromapping/ui/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/colors.dart';
import '../../view_models/cart_view_model.dart';
import '../../view_models/profile_view_model.dart';
import 'feiras_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> _buildWidgets(bool isSeller) {
    if (isSeller) {
      return const [
        HomeScreen(),
        FeirasScreen(),
        DashboardVendedorScreen(),
        CartScreen(),
        ProfileScreen(),
      ];
    }
    return const [
      HomeScreen(),
      FeirasScreen(),
      CartScreen(),
      ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> _buildNavItems(bool isSeller, int cartCount) {
    final cartItem = BottomNavigationBarItem(
      icon: Badge(
        isLabelVisible: cartCount > 0,
        label: Text('$cartCount'),
        child: const Icon(Icons.shopping_bag_outlined),
      ),
      activeIcon: Badge(
        isLabelVisible: cartCount > 0,
        label: Text('$cartCount'),
        child: const Icon(Icons.shopping_bag),
      ),
      label: 'Carrinho',
    );

    if (isSeller) {
      return [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Feiras',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.storefront_outlined),
          activeIcon: Icon(Icons.storefront),
          label: 'Dashboard',
        ),
        cartItem,
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ];
    }

    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map),
        label: 'Feiras',
      ),
      cartItem,
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = context.watch<CartViewModel>();
    final profileViewModel = context.watch<ProfileViewModel>();
    final isSeller = profileViewModel.user?.isSeller ?? false;

    final widgets = _buildWidgets(isSeller);
    final maxIndex = widgets.length - 1;
    final safeIndex = _selectedIndex > maxIndex ? 0 : _selectedIndex;

    return Scaffold(
      body: Center(child: widgets.elementAt(safeIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: BottomNavigationBar(
              currentIndex: safeIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: primaryColor,
              unselectedItemColor: subtitleColor,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: _buildNavItems(isSeller, cartViewModel.itemCount),
            ),
          ),
        ),
      ),
    );
  }
}
