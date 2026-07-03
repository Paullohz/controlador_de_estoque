import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _phone = '';
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String userId = currentUser?.uid ?? '';
    if (userId.isEmpty) {
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Acessar o campo direto no DocumentSnapshot (userDoc['campo']) lança
      // erro se a chave não existir no documento. Lendo o mapa cru com
      // data(), um campo ausente simplesmente vira null, sem quebrar os
      // outros campos que existem.
      final data = userDoc.data() as Map<String, dynamic>? ?? {};

      setState(() {
        _name = (data['name'] ?? '') as String;
        _email = (data['email'] ?? currentUser?.email ?? '') as String;
        _phone = (data['phone'] ?? '') as String;
        _imageUrl = (data['imageUrl'] ?? '') as String;
      });
    } catch (e) {
      // Mantém os campos vazios se não for possível carregar os dados.
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  Text('Perfil', style: AppTextStyles.heading),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileAvatar(radius: 52, imageUrl: _imageUrl),
                      const SizedBox(height: 14),
                      Text(
                        _name.isEmpty ? 'Seu nome' : _name,
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 28),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          children: [
                            _ProfileInfoRow(
                              icon: Icons.mail_outline,
                              label: 'Email',
                              value: _email,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.surfaceHigh,
                              indent: 68,
                            ),
                            _ProfileInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Telefone',
                              value: _phone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.pushNamed(context, '/edit_profile');
                            // Ao voltar da edição, recarrega os dados para
                            // refletir o que foi salvo (ou continuar
                            // mostrando o que já estava, se nada mudou).
                            _loadUserData();
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: AppColors.accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            'Editar perfil',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _signOut,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: Text(
                          'Sair da conta',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.accentSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? 'Não informado' : value,
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
