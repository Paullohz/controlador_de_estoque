import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/pages/add_produtos.dart';
import 'package:flutter_shiftsync/pages/profilescreen.dart';
import 'package:flutter_shiftsync/pages/ProductsListScreen.dart';
import 'package:flutter_shiftsync/widgets/slidable_custom.dart';
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double toolbarHeight =
        (screenHeight <= 740 && screenWidth <= 360) ? 60.0 : 65.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: const Color(0xff303841),
        automaticallyImplyLeading: true,
        toolbarHeight: toolbarHeight,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 15),
            child: Text(
              "LOGO",
              style: TextStyle(
                fontSize: 30,
                color: Color(0xffD72323),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      extendBody: true,
      backgroundColor: Color(0xff303841),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        color: Color(0xff303841),
        backgroundColor: Colors.transparent,
        items: const [
          Icon(Icons.list_alt, size: 30, color: Color(0XFFD72323)),
          Icon(Icons.add, size: 30, color: Color(0XFFD72323)),
          Icon(Icons.person, size: 30, color: Color(0XFFD72323)),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
