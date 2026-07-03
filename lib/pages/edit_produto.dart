import 'package:flutter/material.dart';
import 'package:flutter_shiftsync/models/produtos.dart';
import 'package:flutter_shiftsync/repositories/produtos_repository.dart';
import 'package:flutter_shiftsync/theme/app_theme.dart';
import 'package:flutter_shiftsync/widgets/app_dialogs.dart';
import 'package:flutter_shiftsync/widgets/product_avatar.dart';

const _unidadeOptions = <String>[
  'unidade',
  'kg',
  'g',
  'litro',
  'ml',
  'caixa',
  'pacote',
  'metro',
];

/// Resultado devolvido pela tela de edição: ou o produto foi atualizado,
/// ou o usuário pediu pra excluí-lo (a exclusão de fato é feita por quem
/// chamou a tela, pra não duplicar a chamada ao repositório).
class ProdutoEditResult {
  final Produto? updated;
  final bool deleted;

  const ProdutoEditResult.updated(Produto produto)
      : updated = produto,
        deleted = false;

  const ProdutoEditResult.deleted()
      : updated = null,
        deleted = true;
}

class EditProdutoScreen extends StatefulWidget {
  final Produto produto;

  const EditProdutoScreen({Key? key, required this.produto}) : super(key: key);

  @override
  State<EditProdutoScreen> createState() => _EditProdutoScreenState();
}

class _EditProdutoScreenState extends State<EditProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProdutosRepository _repository = ProdutosRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _categoriaController;
  late final TextEditingController _skuController;
  late final TextEditingController _descricaoController;
  late final TextEditingController _quantidadeController;
  late final TextEditingController _estoqueMinimoController;
  late final TextEditingController _fornecedorController;
  late final TextEditingController _localizacaoController;
  late final TextEditingController _precoCustoController;
  late final TextEditingController _precoVendaController;

  late String _unidade;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    _nameController = TextEditingController(text: produto.nome);
    _categoriaController = TextEditingController(text: produto.categoria);
    _skuController = TextEditingController(text: produto.sku ?? '');
    _descricaoController = TextEditingController(text: produto.descricao ?? '');
    _quantidadeController = TextEditingController(text: produto.quantidade.toString());
    _estoqueMinimoController = TextEditingController(
      text: produto.estoqueMinimo?.toString() ?? '',
    );
    _fornecedorController = TextEditingController(text: produto.fornecedor ?? '');
    _localizacaoController = TextEditingController(text: produto.localizacao ?? '');
    _precoCustoController = TextEditingController(text: produto.precoCusto.toStringAsFixed(2));
    _precoVendaController = TextEditingController(text: produto.preco.toStringAsFixed(2));
    _unidade = _unidadeOptions.contains(produto.unidade) ? produto.unidade : 'unidade';

    // Redesenha o ícone do produto e o indicador de estoque conforme
    // o usuário edita.
    _nameController.addListener(_refresh);
    _quantidadeController.addListener(_refresh);
    _estoqueMinimoController.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _quantidadeController.removeListener(_refresh);
    _estoqueMinimoController.removeListener(_refresh);
    _nameController.dispose();
    _categoriaController.dispose();
    _skuController.dispose();
    _descricaoController.dispose();
    _quantidadeController.dispose();
    _estoqueMinimoController.dispose();
    _fornecedorController.dispose();
    _localizacaoController.dispose();
    _precoCustoController.dispose();
    _precoVendaController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, IconData icon) {
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
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
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

  Widget _optionalTag() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text('(opcional)', style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
    );
  }

  Widget _buildStockStatus() {
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
    final minimo = int.tryParse(_estoqueMinimoController.text);

    Color color;
    String label;
    if (quantidade <= 0) {
      color = AppColors.danger;
      label = 'Sem estoque';
    } else if (minimo != null && quantidade <= minimo) {
      color = AppColors.warning;
      label = 'Estoque baixo';
    } else {
      color = AppColors.accent;
      label = 'Em estoque';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.bodyMuted.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final categoria = _categoriaController.text.trim();
    final quantidade = int.parse(_quantidadeController.text);
    final precoCusto = double.parse(_precoCustoController.text.replaceAll(',', '.'));
    final precoVenda = double.parse(_precoVendaController.text.replaceAll(',', '.'));
    final sku = _skuController.text.trim().isEmpty ? null : _skuController.text.trim();
    final estoqueMinimo = _estoqueMinimoController.text.trim().isEmpty
        ? null
        : int.tryParse(_estoqueMinimoController.text.trim());
    final fornecedor = _fornecedorController.text.trim().isEmpty ? null : _fornecedorController.text.trim();
    final descricao = _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim();
    final localizacao = _localizacaoController.text.trim().isEmpty ? null : _localizacaoController.text.trim();

    try {
      await _repository.updateProduto(widget.produto.id, {
        'nome': name,
        'categoria': categoria,
        'quantidade': quantidade,
        'unidade': _unidade,
        'precoCusto': precoCusto,
        'preco': precoVenda,
        'sku': sku,
        'estoqueMinimo': estoqueMinimo,
        'fornecedor': fornecedor,
        'descricao': descricao,
        'localizacao': localizacao,
      });

      if (!mounted) return;

      final updated = Produto(
        id: widget.produto.id,
        icone: widget.produto.icone,
        nome: name,
        categoria: categoria,
        quantidade: quantidade,
        unidade: _unidade,
        precoCusto: precoCusto,
        preco: precoVenda,
        favorito: widget.produto.favorito,
        sku: sku,
        estoqueMinimo: estoqueMinimo,
        fornecedor: fornecedor,
        descricao: descricao,
        localizacao: localizacao,
      );

      await showAppSuccessDialog(
        context,
        title: 'Produto atualizado',
        message: '"$name" foi salvo com as novas informações.',
        icon: Icons.check_circle_outline_rounded,
      );

      if (!mounted) return;
      Navigator.pop(context, ProdutoEditResult.updated(updated));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      await showAppErrorDialog(context, title: 'Não foi possível salvar', message: '$e');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Excluir produto',
      message: 'Tem certeza que deseja excluir "${widget.produto.nome}"? Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed) {
      if (!mounted) return;
      Navigator.pop(context, const ProdutoEditResult.deleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.ink,
        title: Text('Editar produto', style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              Center(
                child: ProductAvatar(
                  nome: _nameController.text,
                  imageUrl: widget.produto.icone,
                  size: 84,
                  radius: AppRadius.lg,
                ),
              ),
              const SizedBox(height: 28),

              _sectionLabel('Detalhes'),
              TextFormField(
                controller: _nameController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _fieldDecoration('Nome do produto', Icons.sell_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira o nome do produto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoriaController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _fieldDecoration('Categoria', Icons.category_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Insira a categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Código/SKU', style: AppTextStyles.label),
                  _optionalTag(),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _skuController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _fieldDecoration('Ex.: SKU-0001', Icons.qr_code_2_outlined),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Descrição', style: AppTextStyles.label),
                  _optionalTag(),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descricaoController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                maxLines: 3,
                decoration: _fieldDecoration('Detalhes do produto', Icons.notes_outlined),
              ),

              const SizedBox(height: 24),
              _sectionLabel('Preços'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoCustoController,
                      cursorColor: AppColors.accent,
                      style: AppTextStyles.body,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration('Preço de custo', Icons.shopping_cart_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Insira o custo';
                        if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _precoVendaController,
                      cursorColor: AppColors.accent,
                      style: AppTextStyles.body,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration('Preço de venda', Icons.attach_money),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Insira o preço';
                        if (double.tryParse(value.replaceAll(',', '.')) == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel('Estoque'),
                  _buildStockStatus(),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantidadeController,
                      cursorColor: AppColors.accent,
                      style: AppTextStyles.body,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration('Quantidade', Icons.inventory_2_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Insira a qtd.';
                        if (int.tryParse(value) == null) return 'Valor inválido';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _unidade,
                      dropdownColor: AppColors.surface,
                      style: AppTextStyles.body,
                      icon: Icon(Icons.expand_more, color: AppColors.textMuted),
                      decoration: _fieldDecoration('Unidade', Icons.straighten),
                      items: _unidadeOptions
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _unidade = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Estoque mínimo', style: AppTextStyles.label),
                  _optionalTag(),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _estoqueMinimoController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                keyboardType: TextInputType.number,
                decoration: _fieldDecoration('Ex.: 5', Icons.warning_amber_outlined),
                validator: (value) {
                  if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _sectionLabel('Logística'),
              Row(
                children: [
                  Text('Fornecedor', style: AppTextStyles.label),
                  _optionalTag(),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _fornecedorController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _fieldDecoration('Nome do fornecedor', Icons.local_shipping_outlined),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Localização no estoque', style: AppTextStyles.label),
                  _optionalTag(),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _localizacaoController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _fieldDecoration('Ex.: Prateleira A3', Icons.place_outlined),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
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
                        'Salvar alterações',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isSaving ? null : _confirmDelete,
                style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                child: Text(
                  'Excluir produto',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
