import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    Future<void> signIn(BuildContext context) async {
      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pushReplacementNamed(context, '/menu');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('Nenhum usuário encontrado para esse email.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nenhum usuário encontrado para esse email.')),
          );
        } else if (e.code == 'wrong-password') {
          print('Senha errada fornecida para esse usuário.');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Senha errada fornecida para esse usuário.')),
          );
        } else {
          print('Erro ao fazer login: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao fazer login: ${e.message}')),
          );
        }
      } catch (e) {
        print('Erro desconhecido: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro desconhecido: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF303841),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 50),
        color: const Color(0xFF303841),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.2,
                  vertical: 40,
                ),
                child: const Text(
                  "LOGO",
                  style: TextStyle(
                    color: Color(0xFFD72323),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                "Bem-vindo ao App!",
                style: TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Digite os dados de acesso nos campos abaixo",
                style: TextStyle(
                  color: Color(0xFFEEEEEE),
                ),
              ),
              const SizedBox(height: 30),
              CupertinoTextField(
                controller: emailController,
                cursorColor: const Color(0xFFD72323),
                padding: const EdgeInsets.all(15),
                placeholder: "Email",
                placeholderStyle: const TextStyle(
                  color: Color(0xFFD72323),
                  fontSize: 14,
                ),
                style: const TextStyle(
                  color: Color(0xFFD72323),
                  fontSize: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 30),
              CupertinoTextField(
                controller: passwordController,
                padding: const EdgeInsets.all(15),
                placeholder: "Senha",
                obscureText: true,
                placeholderStyle: const TextStyle(
                  color: Color(0xFFD72323),
                  fontSize: 14,
                ),
                style: const TextStyle(
                  color: Color(0xFFD72323),
                  fontSize: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(17),
                  color: const Color(0xFF3A4750),
                  child: const Text(
                    "Acessar",
                    style: TextStyle(
                      color: Color(0xFFD72323),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor, preencha todos os campos.')),
                      );
                    } else {
                      await signIn(context); // Chame o método signIn com o contexto atual
                    }
                  },
                ),
              ),
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF303841),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: CupertinoButton(
                  color: const Color(0xFFD72323),
                  child: const Text(
                    "Registrar-se",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
