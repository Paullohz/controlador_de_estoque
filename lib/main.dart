import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/firebase_options.dart';
import 'package:flutter_shiftsync/pages/add_produtos.dart';
import 'package:flutter_shiftsync/pages/login_page.dart';
import 'package:flutter_shiftsync/pages/profilescreen.dart';
import 'package:flutter_shiftsync/pages/ProductsListScreen.dart';
import 'package:flutter_shiftsync/widgets/slidable_custom.dart';
import 'package:flutter_shiftsync/pages/menu_page.dart'; // Certifique-se de que o nome do arquivo esteja correto
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controlador de Estoque', // Atualizei o título para o novo nome do projeto
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Defina uma rota inicial
      routes: {
        '/login': (context) => LoginPage(),
        '/menu': (context) => MenuPage(),
        '/add_produtos': (context) => AddProdutos(),
        '/profile': (context) => ProfileScreen(),
        '/products_list': (context) => ProductsListScreen(),
      },
    );
  }
}
