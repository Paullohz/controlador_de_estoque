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

class AddProdutos extends StatefulWidget {
  const AddProdutos({Key? key}) : super(key: key);

  @override
  _AddProdutosState createState() => _AddProdutosState();
}

class _AddProdutosState extends State<AddProdutos> {
  final _formKey = GlobalKey<FormState>();
  final ProdutosRepository _repository = ProdutosRepository();

  final _nameController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _skuController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();
  final _fornecedorController = TextEditingController();
  final _localizacaoController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _precoVendaController = TextEditingController();

  String _unidade = 'unidade';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Redesenha o ícone do produto e o indicador de estoque conforme
    // o usuário digita.
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

  Widget _optionalTag() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Text('(opcional)', style: AppTextStyles.bodyMuted.copyWith(fontSize: 11)),
    );
  }

  void _showSuccessDialog({
    required String nome,
    required int quantidade,
    required String unidade,
    required double preco,
  }) {
    showAppSuccessDialog(
      context,
      title: 'Produto adicionado',
      message: '"$nome" já está no seu estoque.',
      extra: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _summaryItem('Quantidade', '$quantidade $unidade'),
            _summaryItem('Preço de venda', 'R\$ ${preco.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showAppErrorDialog(context, message: message);
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

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final nome = _nameController.text.trim();

      Produto newProduto = Produto(
        icone: '',
        nome: nome,
        categoria: _categoriaController.text.trim(),
        quantidade: int.parse(_quantidadeController.text),
        unidade: _unidade,
        precoCusto: double.parse(_precoCustoController.text.replaceAll(',', '.')),
        preco: double.parse(_precoVendaController.text.replaceAll(',', '.')),
        sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
        estoqueMinimo: _estoqueMinimoController.text.trim().isEmpty
            ? null
            : int.tryParse(_estoqueMinimoController.text.trim()),
        fornecedor: _fornecedorController.text.trim().isEmpty ? null : _fornecedorController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
        localizacao: _localizacaoController.text.trim().isEmpty ? null : _localizacaoController.text.trim(),
      );

      await _repository.addProduto(newProduto);

      // Guarda os valores antes de limpar os controllers, já que o
      // conteúdo do diálogo só é montado no próximo frame — se ele lesse
      // os controllers diretamente, apareceria tudo em branco.
      _showSuccessDialog(
        nome: newProduto.nome,
        quantidade: newProduto.quantidade,
        unidade: newProduto.unidade,
        preco: newProduto.preco,
      );

      // Limpar o formulário após adicionar o produto
      _formKey.currentState?.reset();
      _nameController.clear();
      _categoriaController.clear();
      _skuController.clear();
      _descricaoController.clear();
      _quantidadeController.clear();
      _estoqueMinimoController.clear();
      _fornecedorController.clear();
      _localizacaoController.clear();
      _precoCustoController.clear();
      _precoVendaController.clear();
      setState(() {
        _unidade = 'unidade';
        _isSaving = false;
      });
    } catch (error) {
      setState(() {
        _isSaving = false;
      });
      _showErrorDialog('Ocorreu um erro ao adicionar o produto: $error');
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            children: <Widget>[
              Text('Adicionar produto', style: AppTextStyles.heading),
              const SizedBox(height: 4),
              Text(
                'Cadastre um novo item no estoque',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    ProductAvatar(nome: _nameController.text, size: 84, radius: AppRadius.lg),
                    const SizedBox(height: 10),
                    Text(
                      'Ícone gerado a partir do nome do produto',
                      style: AppTextStyles.bodyMuted,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _sectionLabel('Detalhes'),
              TextFormField(
                controller: _nameController,
                cursorColor: AppColors.accent,
                style: AppTextStyles.body,
                decoration: _buildInputDecoration('Nome do produto', Icons.sell_outlined),
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
                decoration: _buildInputDecoration('Categoria', Icons.category_outlined),
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
                decoration: _buildInputDecoration('Ex.: SKU-0001', Icons.qr_code_2_outlined),
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
                decoration: _buildInputDecoration('Detalhes do produto', Icons.notes_outlined),
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
                      decoration: _buildInputDecoration('Preço de custo', Icons.shopping_cart_outlined),
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
                      decoration: _buildInputDecoration('Preço de venda', Icons.attach_money),
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
                      decoration: _buildInputDecoration('Quantidade', Icons.inventory_2_outlined),
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
                      decoration: _buildInputDecoration('Unidade', Icons.straighten),
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
                decoration: _buildInputDecoration('Ex.: 5', Icons.warning_amber_outlined),
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
                decoration: _buildInputDecoration('Nome do fornecedor', Icons.local_shipping_outlined),
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
                decoration: _buildInputDecoration('Ex.: Prateleira A3', Icons.place_outlined),
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
