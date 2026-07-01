import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_shiftsync/pages/menu_page.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String _name = 'Paullo Henrique';
  String _email = 'paullohenriquecastrosilva@gmail.com';
  String _phone = '(62) 98446-4742';
  String _imageUrl = 'assets/Profile.jpg'; 

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Substitua 'users' e 'userId' com a coleção e documento do Firestore corretos
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc('userId')
        .get();

    setState(() {
      _name = userDoc['name'];
      _email = userDoc['email'];
      _phone = userDoc['phone'];
      _imageUrl = userDoc['imageUrl'];

      _nameController.text = _name;
      _emailController.text = _email;
      _phoneController.text = _phone;
    });
  }

  Future<void> _saveUserData() async {
    // Substitua 'users' e 'userId' com a coleção e documento do Firestore corretos
    await FirebaseFirestore.instance.collection('users').doc('userId').update({
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'imageUrl': _imageUrl,
      // Adicione mais campos conforme necessário
    });

    // Exibir um feedback visual (como uma Snackbar) se necessário
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.ink,
        title: Text(
          'Editar Perfil',
          style: AppTextStyles.heading,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: AppColors.ink,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 13),
                child: Text(
                  'Alterar Foto',
                  style: AppTextStyles.subheading,
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Adicione funcionalidade para alterar a foto aqui
              },
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: AppColors.surfaceHigh,
                  backgroundImage: AssetImage(_imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: const Alignment(-0.8, 0),
              child: Text(
                'Alterar Dados',
                style: AppTextStyles.subheading,
              ),
            ),
            const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTextField(_nameController, 'Nome', Icons.person),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTextField(_phoneController, 'Telefone', Icons.phone),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTextField(_emailController, 'Email', Icons.mail),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPasswordField(_passwordController, 'Senha Atual', Icons.lock),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPasswordField(_newPasswordController, 'Nova Senha', Icons.lock_outline),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPasswordField(_confirmPasswordController, 'Confirmar Nova Senha', Icons.lock_outline),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Text(
                  'Salvar Alterações',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.all(15),
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        title: TextFormField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.label,
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: AppColors.accent),
          ),
        ),
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ListTile(
        title: TextFormField(
          controller: controller,
          obscureText: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.label,
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: AppColors.accent),
          ),
        ),
        tileColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
