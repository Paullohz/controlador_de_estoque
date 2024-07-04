import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/repositories/produtos_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductsListScreen extends StatelessWidget {
  final ProdutosRepository produtosRepository = ProdutosRepository();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double toolbarHeight = (screenHeight <= 740 && screenWidth <= 360) ? 40.0 : 65.0;

    return Stack(
      children: <Widget>[
        Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff303841), Color(0xffEEEEEE)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.2, 0.2],
            ),
          ),
        ),
        Positioned(
          top: toolbarHeight + 15,
          left: 20,
          right: 20,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Color(0XFFEEEEEE),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Color(0XFFD72323),
                  spreadRadius: 2,
                  blurRadius: 3,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Pesquisar',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: toolbarHeight + 55,
          left: 0,
          right: 0,
          child: Container(
            height: screenHeight * 0.2,
            width: screenWidth,
            child: SvgPicture.asset(
              'assets/logo.svg',
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Positioned(
          top: toolbarHeight + 148,
          left: 0,
          right: 0,
          bottom: 56,
          child: FutureBuilder<List<Produto>>(
            future: produtosRepository.getProdutos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erro ao carregar produtos: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('Nenhum produto encontrado.'));
              } else {
                var produtos = snapshot.data!;
                return ListView.separated(
                  padding: EdgeInsets.all(16),
                  itemCount: produtos.length,
                  itemBuilder: (BuildContext context, int index) {
                    var produto = produtos[index];
                    return ListTile(
                      leading: SizedBox(
                        height: 50, // Defina a altura desejada para a imagem
                        width: 50, // Defina a largura desejada para a imagem
                        child: Image.network(
                          produto.icone,
                          fit: BoxFit.cover, // Ajusta a imagem para cobrir o espaço definido
                        ),
                      ),
                      title: Center(
                        child: Text(
                          produto.nome,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      trailing: Text('R\$ ${produto.preco.toStringAsFixed(2)}'),
                    );
                  },
                  separatorBuilder: (__, ___) => Divider(),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
