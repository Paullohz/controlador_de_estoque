import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/repositories/produtos_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';

class AddProdutos extends StatefulWidget {
  const AddProdutos({Key? key}) : super(key: key);

  @override
  _AddProdutosState createState() => _AddProdutosState();
}

class _AddProdutosState extends State<AddProdutos> {
  final _formKey = GlobalKey<FormState>();
  final ProdutosRepository _repository = ProdutosRepository();
  String _productName = '';
  double _productPrice = 0.0;
  String _productCategory = 'Categoria 1';
  bool _inStock = false;
  int _productQuantity = 0;
  String _productImage = ''; // URL da imagem do produto no Firebase Storage
  File? _selectedImage;
  bool _isSaving = false;

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.surfaceHigh,
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
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final fileName =
          'produtos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      final uploadTask = await ref.putFile(image);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      return null;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    setState(() {
      _isSaving = true;
    });

    try {
      String imageUrl = _productImage;
      if (_selectedImage != null) {
        final uploadedUrl = await _uploadImage(_selectedImage!);
        if (uploadedUrl == null) {
          setState(() {
            _isSaving = false;
          });
          _showErrorDialog('Não foi possível enviar a imagem do produto. Tente novamente.');
          return;
        }
        imageUrl = uploadedUrl;
      }

      Produto newProduto = Produto(
        icone: imageUrl,
        nome: _productName,
        sigla: _productCategory,
        preco: _productPrice,
      );

      await _repository.addProduto(newProduto);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Produto Adicionado'),
          content: Text('Nome: $_productName\nPreço: R\$ $_productPrice'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

      // Limpar o formulário após adicionar o produto
      _formKey.currentState?.reset();
      setState(() {
        _selectedImage = null;
        _productImage = '';
        _isSaving = false;
      });
    } catch (error) {
      setState(() {
        _isSaving = false;
      });
      _showErrorDialog('Ocorreu um erro ao adicionar o produto: $error');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            children: <Widget>[
              Text('Adicionar Produto', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Preencha os dados do novo produto',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 20),
              TextFormField(
                cursorColor: AppColors.accent,
                decoration: _buildInputDecoration('Nome do Produto'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do produto';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productName = value!;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                cursorColor: AppColors.accent,
                decoration: _buildInputDecoration('Preço do Produto'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o preço do produto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productPrice = double.parse(value!);
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                cursorColor: AppColors.accent,
                decoration: _buildInputDecoration('Quantidade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a quantidade do produto';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, insira um número válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  _productQuantity = int.parse(value!);
                },
              ),
              SizedBox(height: 16.0),
              if (_selectedImage != null)
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(bottom: 16.0), // Espaço entre a imagem e o botão
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              TextButton.icon(
                onPressed: _pickImageFromGallery,
                icon: Icon(Icons.image_outlined, color: AppColors.accentSecondary),
                label: Text(
                  _selectedImage == null
                      ? 'Selecionar Imagem do Produto'
                      : 'Imagem Selecionada',
                  style: AppTextStyles.body,
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: AppColors.surfaceHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text(
                  'Produto em Estoque',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                value: _inStock,
                checkColor: Colors.white,
                activeColor: AppColors.accent,
                onChanged: (value) {
                  setState(() {
                    _inStock = value!;
                  });
                },
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                child: _isSaving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Adicionar Produto',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
