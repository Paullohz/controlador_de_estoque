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

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMuted,
      prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
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
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: AppColors.accentSecondary),
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
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('Erro', style: AppTextStyles.subheading),
        content: Text(message, style: AppTextStyles.body),
        actions: <Widget>[
          TextButton(
            child: Text('OK', style: TextStyle(color: AppColors.accent)),
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
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          title: Text('Produto adicionado', style: AppTextStyles.subheading),
          content: Text(
            'Nome: $_productName\nPreço: R\$ $_productPrice',
            style: AppTextStyles.body,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: TextStyle(color: AppColors.accent)),
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

  Widget _buildPhotoPicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImageFromGallery,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.surfaceHigh, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, fit: BoxFit.cover)
                    : Icon(Icons.photo_outlined, color: AppColors.accentSecondary, size: 30),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 3),
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: AppColors.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _selectedImage == null ? 'Toque para adicionar uma foto' : 'Toque para trocar a foto',
          style: AppTextStyles.bodyMuted,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: <Widget>[
              Text('Adicionar produto', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Cadastre um novo item no estoque',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 24),
              Center(child: _buildPhotoPicker()),
              const SizedBox(height: 28),
              _sectionLabel('Detalhes'),
              TextFormField(
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _buildInputDecoration('Nome do produto', Icons.sell_outlined),
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
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      cursorColor: AppColors.accent,
                      style: AppTextStyles.body,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _buildInputDecoration('Preço', Icons.attach_money),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira o preço';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _productPrice = double.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      cursorColor: AppColors.accent,
                      style: AppTextStyles.body,
                      keyboardType: TextInputType.number,
                      decoration: _buildInputDecoration('Qtd.', Icons.inventory_2_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira a qtd.';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Valor inválido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _productQuantity = int.parse(value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionLabel('Estoque'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Produto em estoque',
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Switch(
                      value: _inStock,
                      activeColor: AppColors.accent,
                      onChanged: (value) {
                        setState(() {
                          _inStock = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _isSaving ? null : _submit,
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
                        'Adicionar produto',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
