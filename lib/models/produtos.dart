class Produto {
  String id;
  String icone;
  String nome;
  String sigla;
  double preco;
  final String? descricao;

  Produto({
    this.id = '',
    required this.icone,
    required this.nome,
    required this.sigla,
    required this.preco,
    this.descricao,
  });

  factory Produto.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Produto(
      id: documentId,
      icone: data['icone'],
      nome: data['nome'],
      sigla: data['sigla'],
      preco: data['preco'].toDouble(),
      descricao: data['descricao'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'icone': icone,
      'nome': nome,
      'sigla': sigla,
      'preco': preco,
      'descricao': descricao,
    };
  }
}
