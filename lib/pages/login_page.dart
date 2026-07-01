import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/app_logo.dart';

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
      backgroundColor: AppColors.ink,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 50),
        color: AppColors.ink,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AppLogo(height: 56),
              ),
              Text(
                "Bem-vindo ao App!",
                style: AppTextStyles.display.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                "Digite os dados de acesso nos campos abaixo",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 30),
              CupertinoTextField(
                controller: emailController,
                cursorColor: AppColors.accent,
                padding: const EdgeInsets.all(15),
                placeholder: "Email",
                placeholderStyle: AppTextStyles.bodyMuted,
                style: AppTextStyles.body,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: 20),
              CupertinoTextField(
                controller: passwordController,
                cursorColor: AppColors.accent,
                padding: const EdgeInsets.all(15),
                placeholder: "Senha",
                obscureText: true,
                placeholderStyle: AppTextStyles.bodyMuted,
                style: AppTextStyles.body,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(17),
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Text(
                    "Acessar",
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
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
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(17),
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Text(
                    "Registrar-se",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.accentSecondary,
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
