import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/pages/login_page.dart';
import 'package:flutter_shiftsync/pages/menu_page.dart';
import 'package:flutter_shiftsync/pages/add_produtos.dart';
import 'package:flutter_shiftsync/pages/profilescreen.dart';
import 'package:flutter_shiftsync/pages/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

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
      title: 'ShiftSync',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/menu': (context) => MenuPage(),
        '/add_produtos': (context) => AddProdutos(),
        '/profile': (context) => ProfileScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
