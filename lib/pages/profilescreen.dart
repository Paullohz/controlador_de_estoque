import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double toolbarHeight = 65.0; // Altura padrão da AppBar

  String _name = '';
  String _email = '';
  String _phone = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      print('No user logged in.');
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      setState(() {
        _name = userDoc['name'];
        _email = userDoc['email'];
        _phone = userDoc['phone'];
        _imageUrl = userDoc['imageUrl'];
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // Ajustando altura da AppBar e padding conforme o tamanho da tela
    if (screenHeight <= 740 && screenWidth <= 360) {
      toolbarHeight = 20.0;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff303841),
        automaticallyImplyLeading: false,
        toolbarHeight: toolbarHeight,
      ),
      backgroundColor: const Color(0xff3A4750),
      body: Column(
        children: [
          Container(
            height: 50, // Altura do gradiente
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff303841),
                  Color(0xff3A4750),
                ],
              ),
            ),
            child: Center(
              child: Text(
                'Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Color(0xFFD72323),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: _imageUrl.isNotEmpty
                          ? NetworkImage(_imageUrl)
                          : AssetImage('assets/Profile.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ItemProfile('Nome', _name, CupertinoIcons.person),
                  const SizedBox(height: 20),
                  ItemProfile('Email', _email, CupertinoIcons.mail_solid),
                  const SizedBox(height: 20),
                  ItemProfile('Telefone', _phone, CupertinoIcons.phone),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                    child: const Text(
                      'Editar Perfil',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 50),
                      backgroundColor: Color(0xFFD72323),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget ItemProfile(String title, String subtitle, IconData iconData) {
  return Container(
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 65, 85, 98),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          offset: Offset(0, 5),
          color: Colors.black.withOpacity(.1),
          spreadRadius: 2,
          blurRadius: 6,
        ),
      ],
    ),
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(color: Color(0xFFD72323)),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Icon(
        iconData,
        color: Color(0xFFD72323),
      ),
      tileColor: Color.fromARGB(255, 65, 85, 98),
    ),
  );
}
