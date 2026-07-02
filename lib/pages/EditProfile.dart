import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
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
  String _imageUrl = '';
  File? _selectedImage;
  bool _isSaving = false;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      setState(() {
        _name = (userDoc['name'] ?? '') as String;
        _email = (userDoc['email'] ?? '') as String;
        _phone = (userDoc['phone'] ?? '') as String;
        _imageUrl = (userDoc['imageUrl'] ?? '') as String;

        _nameController.text = _name;
        _emailController.text = _email;
        _phoneController.text = _phone;
      });
    } catch (e) {
      // Mantém os campos vazios se não for possível carregar os dados.
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveUserData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'imageUrl': _imageUrl,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $e')),
      );
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
            Center(
              child: ProfileAvatar(
                radius: 52,
                localFile: _selectedImage,
                imageUrl: _imageUrl,
                editable: true,
                onTap: _pickImage,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                _selectedImage == null ? 'Toque para alterar a foto' : 'Foto selecionada',
                style: AppTextStyles.bodyMuted,
              ),
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
