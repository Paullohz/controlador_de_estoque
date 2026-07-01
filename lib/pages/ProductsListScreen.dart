import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/repositories/produtos_repository.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/app_logo.dart';
import 'package:flutter_shiftsync/widgets/slidable_custom.dart';

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

  void _removeProduct(String productId) async {
    try {
      await produtosRepository.deleteProduto(productId);
      setState(() {
        _displayedProducts.removeWhere((produto) => produto.id == productId);
        _allProducts.removeWhere((produto) => produto.id == productId);
      });
    } catch (error) {
      print('Erro ao excluir produto: $error');
    }
  }

  void _updateProductImage(String productId, String newImageUrl) async {
    try {
      await produtosRepository.updateProdutoIcone(productId, newImageUrl);
      setState(() {
        for (var produto in _allProducts) {
          if (produto.id == productId) produto.icone = newImageUrl;
        }
        for (var produto in _displayedProducts) {
          if (produto.id == productId) produto.icone = newImageUrl;
        }
      });
    } catch (error) {
      print('Erro ao atualizar imagem do produto: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(height: 36),
                  const SizedBox(height: 20),
                  Text('Produtos cadastrados', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text(
                    '${_allProducts.length} ${_allProducts.length == 1 ? 'item' : 'itens'} no estoque',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.textMuted),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: AppTextStyles.body,
                            decoration: InputDecoration(
                              hintText: 'Pesquisar produto',
                              hintStyle: AppTextStyles.bodyMuted,
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: _filterProducts,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _displayedProducts.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _displayedProducts.length,
                      itemBuilder: (BuildContext context, int index) {
                        var produto = _displayedProducts[index];
                        return SlidableCustom(
                          title: produto.nome,
                          subtitle: 'R\$ ${produto.preco.toStringAsFixed(2)}',
                          imageurl: produto.icone,
                          action1: () async {
                            // Ação de editar
                          },
                          action2: () {
                            _removeProduct(produto.id);
                          },
                          onDelete: () {
                            _removeProduct(produto.id);
                          },
                          onImageUpdated: (newImageUrl) {
                            _updateProductImage(produto.id, newImageUrl);
                          },
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'Nenhum produto encontrado',
                            style: AppTextStyles.bodyMuted,
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
