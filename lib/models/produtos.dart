class Produto {
  String id;
  String icone;
  String nome;
  String categoria;
  int quantidade;
  String unidade;
  double precoCusto;
  double preco; // preço de venda
  bool favorito;
  String? sku;
  int? estoqueMinimo;
  String? fornecedor;
  String? descricao;
  String? localizacao;

  Produto({
    this.id = '',
    required this.icone,
    required this.nome,
    required this.categoria,
    this.quantidade = 0,
    this.unidade = 'unidade',
    this.precoCusto = 0.0,
    required this.preco,
    this.favorito = false,
    this.sku,
    this.estoqueMinimo,
    this.fornecedor,
    this.descricao,
    this.localizacao,
  });

  factory Produto.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Produto(
      id: documentId,
      icone: data['icone'] ?? '',
      nome: data['nome'] ?? '',
      // 'sigla' é o nome antigo do campo, mantido só pra ler produtos
      // cadastrados antes dessa mudança.
      categoria: data['categoria'] ?? data['sigla'] ?? '',
      quantidade: (data['quantidade'] ?? 0) as int,
      unidade: data['unidade'] ?? 'unidade',
      precoCusto: (data['precoCusto'] ?? 0).toDouble(),
      preco: (data['preco'] ?? 0).toDouble(),
      favorito: data['favorito'] ?? false,
      sku: data['sku'],
      estoqueMinimo: data['estoqueMinimo'],
      fornecedor: data['fornecedor'],
      descricao: data['descricao'],
      localizacao: data['localizacao'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'icone': icone,
      'nome': nome,
      'categoria': categoria,
      'quantidade': quantidade,
      'unidade': unidade,
      'precoCusto': precoCusto,
      'preco': preco,
      'favorito': favorito,
      'sku': sku,
      'estoqueMinimo': estoqueMinimo,
      'fornecedor': fornecedor,
      'descricao': descricao,
      'localizacao': localizacao,
    };
  }

  /// true se a quantidade estiver em ou abaixo do estoque mínimo definido
  /// (quando não há mínimo cadastrado, considera baixo só quando zerado).
  bool get estoqueBaixo {
    if (quantidade <= 0) return true;
    if (estoqueMinimo != null) return quantidade <= estoqueMinimo!;
    return false;
  }
}
