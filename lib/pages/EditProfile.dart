import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/app_dialogs.dart';
import 'package:flutter_shiftsync/widgets/profile_avatar.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String _name = '';
  String _email = '';
  String _phone = '';
  bool _isSaving = false;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _passwordJustChanged = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid;
    if (userId == null) return;

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

        _nameController.text = _name;
        _emailController.text = _email;
        _phoneController.text = _phone;
      });
    } catch (e) {
      // Mantém os campos vazios se não for possível carregar os dados.
    }
  }

  /// Troca a senha no Firebase Auth se o usuário preencheu os campos de
  /// segurança. Retorna `true` se pode seguir com o resto do salvamento
  /// (nada pedido, ou senha trocada com sucesso) e `false` se algo deu
  /// errado (o erro já foi mostrado ao usuário).
  Future<bool> _updatePasswordIfRequested(User user) async {
    final current = _passwordController.text;
    final newPass = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (current.isEmpty && newPass.isEmpty && confirm.isEmpty) {
      return true;
    }

    if (current.isEmpty) {
      await showAppWarningDialog(
        context,
        title: 'Falta a senha atual',
        message: 'Informe sua senha atual para definir uma nova.',
      );
      return false;
    }
    if (newPass.isEmpty) {
      await showAppWarningDialog(
        context,
        title: 'Falta a nova senha',
        message: 'Informe a nova senha para continuar.',
      );
      return false;
    }
    if (newPass.length < 6) {
      await showAppWarningDialog(
        context,
        title: 'Senha muito curta',
        message: 'A nova senha deve ter ao menos 6 caracteres.',
      );
      return false;
    }
    if (newPass != confirm) {
      await showAppWarningDialog(
        context,
        title: 'Senhas diferentes',
        message: 'A confirmação não coincide com a nova senha.',
      );
      return false;
    }
    if (newPass == current) {
      await showAppWarningDialog(
        context,
        title: 'Senha já cadastrada',
        message: 'A nova senha não pode ser igual à senha atual. Escolha uma senha diferente para continuar.',
      );
      return false;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email ?? _emailController.text,
        password: current,
      );
      // O Firebase exige um login "recente" para trocar a senha, então é
      // preciso reautenticar com a senha atual antes de chamar updatePassword.
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPass);

      _passwordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      _passwordJustChanged = true;
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Senha atual incorreta.';
      } else if (e.code == 'weak-password') {
        message = 'Nova senha muito fraca. Use ao menos 6 caracteres.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Por segurança, saia e entre novamente antes de trocar a senha.';
      } else {
        message = 'Não foi possível trocar a senha: ${e.message}';
      }
      await showAppErrorDialog(context, title: 'Não foi possível trocar a senha', message: message);
      return false;
    }
  }

  Future<void> _saveUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _passwordJustChanged = false;
    setState(() {
      _isSaving = true;
    });

    try {
      final passwordOk = await _updatePasswordIfRequested(user);
      if (!passwordOk) {
        return;
      }

      // .update() falha com "not-found" se o documento ainda não existir
      // (caso de contas antigas cujo cadastro nunca criou o doc no
      // Firestore). .set(..., merge: true) cria o documento se faltar e
      // só atualiza os campos informados se ele já existir.
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      if (_passwordJustChanged) {
        await showAppSuccessDialog(
          context,
          title: 'Senha alterada',
          message: 'Sua senha foi atualizada. Use a nova senha da próxima vez que entrar.',
          icon: Icons.lock_reset_rounded,
        );
      } else {
        await showAppSuccessDialog(
          context,
          title: 'Perfil atualizado',
          message: 'Suas informações foram salvas com sucesso.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showAppErrorDialog(context, title: 'Não foi possível salvar', message: '$e');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _fieldDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMuted,
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: AppColors.accentSecondary),
      ),
    );
  }

  Widget _obscureToggle(bool obscured, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textMuted,
        size: 20,
      ),
      onPressed: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.ink,
        title: Text('Editar perfil', style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // Ícone estático — sem seleção de foto, para não depender do
            // Firebase Storage.
            const Center(
              child: ProfileAvatar(radius: 52),
            ),
            const SizedBox(height: 28),
            _sectionLabel('Dados pessoais'),
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              decoration: _fieldDecoration('Nome', Icons.person_outline),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              keyboardType: TextInputType.phone,
              decoration: _fieldDecoration('Telefone', Icons.phone_outlined),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              keyboardType: TextInputType.emailAddress,
              decoration: _fieldDecoration('Email', Icons.mail_outline),
            ),
            const SizedBox(height: 28),
            _sectionLabel('Segurança'),
            TextFormField(
              controller: _passwordController,
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              obscureText: _obscureCurrent,
              decoration: _fieldDecoration(
                'Senha atual',
                Icons.lock_outline,
                suffixIcon: _obscureToggle(_obscureCurrent, () {
                  setState(() {
                    _obscureCurrent = !_obscureCurrent;
                  });
                }),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _newPasswordController,
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              obscureText: _obscureNew,
              decoration: _fieldDecoration(
                'Nova senha',
                Icons.lock_reset_outlined,
                suffixIcon: _obscureToggle(_obscureNew, () {
                  setState(() {
                    _obscureNew = !_obscureNew;
                  });
                }),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirmPasswordController,
              style: AppTextStyles.body,
              cursorColor: AppColors.accent,
              obscureText: _obscureConfirm,
              decoration: _fieldDecoration(
                'Confirmar nova senha',
                Icons.lock_reset_outlined,
                suffixIcon: _obscureToggle(_obscureConfirm, () {
                  setState(() {
                    _obscureConfirm = !_obscureConfirm;
                  });
                }),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveUserData,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Salvar alterações',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
