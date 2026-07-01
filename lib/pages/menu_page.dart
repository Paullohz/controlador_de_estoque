import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/pages/add_produtos.dart';
import 'package:flutter_shiftsync/pages/profilescreen.dart';
import 'package:flutter_shiftsync/pages/ProductsListScreen.dart';
import 'package:flutter_shiftsync/widgets/slidable_custom.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  final List<Widget> _screens = [
    ProductsListScreen(),
    AddProdutos(),
    ProfileScreen(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      extendBody: true,
      backgroundColor: AppColors.ink,
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        color: AppColors.surface,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: AppColors.accent,
        items: const [
          Icon(Icons.list_alt, size: 28, color: AppColors.textLight),
          Icon(Icons.add, size: 28, color: Colors.white),
          Icon(Icons.person, size: 28, color: AppColors.textLight),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
