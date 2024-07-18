import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  void initState() {
    super.initState();
    _nameController.text = _name;
    _emailController.text = _email;
    _phoneController.text = _phone;
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
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            color: Color(0xFFD72323),
          ),
        ),
        toolbarHeight: toolbarHeight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFD72323)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MenuPage()
              ),
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
              const Color(0XFFEEEEEE), 
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {

                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: AssetImage(_imageUrl),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40), 
                child: SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTextField(_nameController, 'Nome', Icons.person),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTextField(_emailController, 'Email', Icons.mail),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTextField(_phoneController, 'Telefone', Icons.phone),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                },
                child: Text(
                  'Salvar Alterações',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  padding: EdgeInsets.all(15),
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
            labelStyle: const TextStyle(color: const Color(0xFFD72323)),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: const Color(0xFFD72323)),
          ),
        ),
        tileColor: const Color(0xFF3A4750),
      ),
    );
  }
}
