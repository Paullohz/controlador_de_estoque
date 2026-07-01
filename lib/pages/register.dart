import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/app_logo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _allFieldsEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.ink,
        centerTitle: true,
        title: const AppLogo(height: 28),
      ),
      body: Container(
        color: AppColors.ink,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10),
              color: AppColors.ink,
              child: Center(
                child: Text(
                  'Registre-se',
                  style: AppTextStyles.heading,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          prefixIcon: Icon(Icons.person, color: AppColors.accent),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accentSecondary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceHigh,
                        ),
                        style: AppTextStyles.body,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _allFieldsEmpty = _nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                _phoneController.text.isEmpty;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          prefixIcon: Icon(Icons.email, color: AppColors.accent),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accentSecondary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceHigh,
                        ),
                        style: AppTextStyles.body,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _allFieldsEmpty = _nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                _phoneController.text.isEmpty;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          prefixIcon: Icon(Icons.lock, color: AppColors.accent),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accentSecondary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceHigh,
                        ),
                        style: AppTextStyles.body,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _allFieldsEmpty = _nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                _phoneController.text.isEmpty;
                          });
                        },
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telefone',
                          labelStyle: TextStyle(color: AppColors.textMuted),
                          prefixIcon: Icon(Icons.phone, color: AppColors.accent),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accent),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.accentSecondary, width: 1.5),
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceHigh,
                        ),
                        style: AppTextStyles.body,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu telefone';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _allFieldsEmpty = _nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                _phoneController.text.isEmpty;
                          });
                        },
                      ),
                      const SizedBox(height: 40.0),
                      ElevatedButton(
                        onPressed: _allFieldsEmpty
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await _registerUser();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Registro realizado com sucesso!')),
                                    );
                                    Navigator.pushReplacementNamed(context, '/login');
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro ao registrar: $e')),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          minimumSize: const Size(double.infinity, 50.0),
                        ),
                        child: const Text('Salvar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Grava os dados adicionais no Realtime Database
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
      await usersRef.child(userCredential.user!.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
      });
    } catch (e) {
      rethrow;
    }
  }
}
