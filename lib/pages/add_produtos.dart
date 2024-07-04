import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/repositories/produtos_repository.dart';
import 'package:image_picker/image_picker.dart';

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
  String _productImage = ''; // Caminho da imagem do produto

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Color(0xff303841)),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Produto newProduto = Produto(
        icone: _productImage,
        nome: _productName,
        sigla: _productCategory,
        preco: _productPrice,
      );
      _repository.addProduto(newProduto).then((docRef) {
        // Exibir o produto cadastrado
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
      }).catchError((error) {
        // Tratar erros ao adicionar o produto
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erro ao Adicionar Produto'),
            content: Text('Ocorreu um erro ao adicionar o produto: $error'),
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
      });
    }
  }

  void _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _productImage = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double toolbarHeight = (screenHeight <= 740 && screenWidth <= 360) ? 20.0 : 20.0;
    double paddingTop = (screenHeight <= 740 && screenWidth <= 360) ? 20.0 : 4.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xff303841),
        automaticallyImplyLeading: false,
        toolbarHeight: toolbarHeight, // Ajusta a altura da AppBar
      ),
      backgroundColor: const Color(0XFFEEEEEE),
      body: Padding(
        padding: EdgeInsets.only(top: paddingTop),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0), // Adiciona padding lateral
            children: <Widget>[
              TextFormField(
                cursorColor: Color(0xFFD72323),
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
                cursorColor: Color(0xFFD72323),
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
                cursorColor: Color(0xFFD72323),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Expanded(
                    child: TextFormField(
                      cursorColor: Color(0xFFD72323),
                      maxLines: 5,
                      decoration: _buildInputDecoration('Imagem do Produto'),
                      readOnly: true,
                      onTap: _selectImage, // Chama o método ao tocar no campo
                      onSaved: (value) {
                         // Salvar o caminho da imagem selecionada (se necessário)
                        _productImage = value!;
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    iconSize: 40,
                    color: Color(0xff303841),
                    padding: EdgeInsets.only(bottom: 60, right: 60, left: 50),
                    onPressed: _selectImage, // Chama o método ao tocar no ícone
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: Text(
                  'Produto em Estoque',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: _inStock,
                checkColor: Colors.white,
                activeColor: Color(0xFFD72323),
                onChanged: (value) {
                  setState(() {
                    _inStock = value!;
                  });
                },
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _submit,
                child: Text(
                  'Adicionar Produto',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(200, 50),
                  backgroundColor: Color(0xFFD72323),
                  padding: EdgeInsets.symmetric(vertical: 23.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
