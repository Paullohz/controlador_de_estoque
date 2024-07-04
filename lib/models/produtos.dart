class Produto {
  String id;
  String icone;
  String nome;
  String sigla;
  double preco;

  Produto({
    this.id = '',
    required this.icone,
    required this.nome,
    required this.sigla,
    required this.preco,
  });

  // Converte um documento do Firestore em um objeto Produto
  factory Produto.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Produto(
      id: documentId,
      icone: data['icone'],
      nome: data['nome'],
      sigla: data['sigla'],
      preco: data['preco'].toDouble(),
    );
  }

  // Converte um objeto Produto em um mapa para o Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'icone': icone,
      'nome': nome,
      'sigla': sigla,
      'preco': preco,
    };
  }
}
