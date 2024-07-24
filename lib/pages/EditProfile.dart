import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_shiftsync/pages/menu_page.dart';

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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double toolbarHeight =
        (screenHeight <= 740 && screenWidth <= 360) ? 60.0 : 65.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff303841),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(color: Color(0xFFD72323)),
        ),
        toolbarHeight: toolbarHeight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD72323)),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
              (route) => false,
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xff303841),
              const Color(0xffffffff),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    'Alterar Foto',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  // Adicione funcionalidade para alterar a foto aqui
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(_imageUrl),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment(-0.8, 0),
                child: Text(
                  'Alterar Dados',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFFFFF),
                  ),
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
                child: const Text(
                  'Salvar Alterações',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  padding: const EdgeInsets.all(15),
                  backgroundColor: const Color(0xFFD72323),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff303841),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(.1),
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        title: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFFD72323)),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: const Color(0xFFD72323)),
          ),
        ),
        tileColor: const Color(0xFF3A4750),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff303841),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            color: Colors.black.withOpacity(.1),
            spreadRadius: 2,
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        title: TextFormField(
          controller: controller,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Color(0xFFD72323)),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: const Color(0xFFD72323)),
          ),
        ),
        tileColor: const Color(0xFF3A4750),
      ),
    );
  }
}
