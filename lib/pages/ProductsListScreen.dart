import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/pages/edit_produto.dart';
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

  void _replaceProduct(Produto updated) {
    setState(() {
      final idxAll = _allProducts.indexWhere((p) => p.id == updated.id);
      if (idxAll != -1) _allProducts[idxAll] = updated;
      final idxDisplayed = _displayedProducts.indexWhere((p) => p.id == updated.id);
      if (idxDisplayed != -1) _displayedProducts[idxDisplayed] = updated;
    });
  }

  Future<void> _toggleFavorite(Produto produto) async {
    final novoValor = !produto.favorito;

    // Atualização otimista: reflete na hora, desfaz se a gravação falhar.
    setState(() {
      produto.favorito = novoValor;
    });

    try {
      await produtosRepository.setFavorito(produto.id, novoValor);
    } catch (error) {
      setState(() {
        produto.favorito = !novoValor;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível atualizar o favorito.')),
        );
      }
    }
  }

  Future<void> _editProduct(Produto produto) async {
    final result = await Navigator.push<ProdutoEditResult>(
      context,
      MaterialPageRoute(builder: (context) => EditProdutoScreen(produto: produto)),
    );

    if (result == null) return;

    if (result.deleted) {
      _removeProduct(produto.id);
    } else if (result.updated != null) {
      _replaceProduct(result.updated!);
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
                  ? _buildProductList()
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

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.label.copyWith(color: AppColors.accentSecondary),
      ),
    );
  }

  Widget _buildProductTile(Produto produto) {
    final subtitleColor = produto.quantidade <= 0
        ? AppColors.danger
        : produto.estoqueBaixo
            ? AppColors.warning
            : null;

    return SlidableCustom(
      title: produto.nome,
      subtitle: 'R\$ ${produto.preco.toStringAsFixed(2)} · ${produto.quantidade} ${produto.unidade}',
      imageurl: produto.icone,
      favorito: produto.favorito,
      subtitleColor: subtitleColor,
      action1: () async {
        await _editProduct(produto);
      },
      action2: () {
        _removeProduct(produto.id);
      },
      onDelete: () {
        _removeProduct(produto.id);
      },
      onToggleFavorite: () {
        _toggleFavorite(produto);
      },
    );
  }

  Widget _buildProductList() {
    final favoritos = _displayedProducts.where((p) => p.favorito).toList();
    final outros = _displayedProducts.where((p) => !p.favorito).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        if (favoritos.isNotEmpty) ...[
          _buildSectionLabel('Favoritos'),
          ...favoritos.map(_buildProductTile),
          const SizedBox(height: 12),
        ],
        if (outros.isNotEmpty) ...[
          if (favoritos.isNotEmpty) _buildSectionLabel('Todos os produtos'),
          ...outros.map(_buildProductTile),
        ],
      ],
    );
  }
}
