import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/repositories/produtos_repository.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Importando SlidablePage

class ProductsListScreen extends StatefulWidget {
  @override
  _ProductsListScreenState createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final ProdutosRepository produtosRepository = ProdutosRepository();
  List<Produto> _allProducts = [];
  List<Produto> _displayedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      List<Produto> produtos = await produtosRepository.getProdutos();
      setState(() {
        _allProducts = produtos;
        _displayedProducts = produtos;
      });
    } catch (error) {
      print('Erro ao carregar produtos: $error');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _displayedProducts = _allProducts
          .where((produto) =>
              produto.nome.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _displayedProducts.removeAt(index);
    });
  }

  void _navigateToSlidablePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => SlidablePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double toolbarHeight =
        (screenHeight <= 740 && screenWidth <= 360) ? 40.0 : 65.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Products List'),
      ),
      body: Stack(
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
                      onChanged: _filterProducts,
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
            child: _displayedProducts != null
                ? (_displayedProducts.isEmpty
                    ? Center(child: Text('Nenhum produto encontrado.'))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: _displayedProducts.length,
                        itemBuilder: (BuildContext context, int index) {
                          var produto = _displayedProducts[index];
                          return Slidable(
                            key: ValueKey(index),
                            startActionPane: ActionPane(
                              motion: ScrollMotion(),
                              dismissible: DismissiblePane(
                                onDismissed: () {
                                  // Implementação da lógica ao ser dismissível
                                  _removeProduct(index);
                                },
                              ),
                              children: [
                                SlidableAction(
                                  onPressed: () {
                                    // Implementação da lógica ao pressionar a ação
                                    _removeProduct(index);
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                ),
                              ],
                            ),
                            actionExtentRatio: 0.25,
                            child: ListTile(
                              onTap: () {
                                _navigateToSlidablePage(context); // Navega para SlidablePage
                              },
                              leading: SizedBox(
                                height: 50,
                                width: 50,
                                child: Image.network(
                                  produto.icone,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Center(
                                child: Text(
                                  produto.nome,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              trailing: Text(
                                  'R\$ ${produto.preco.toStringAsFixed(2)}'),
                            ),
                          );
                        },
                      ))
                : Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
