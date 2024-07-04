import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_shiftsync/models/produtos.dart';

class ProdutosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Método para adicionar um produto ao Firestore
  Future<DocumentReference> addProduto(Produto produto) async {
    try {
      var docRef = await _firestore.collection('produtos').add(produto.toFirestore());
      return docRef;
    } catch (e) {
      print('Erro ao adicionar produto: $e');
      throw e; // Propagar o erro para tratamento adequado na interface
    }
  }

  // Método para obter todos os produtos do Firestore
  Future<List<Produto>> getProdutos() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('produtos').get();
      return querySnapshot.docs
          .map((doc) =>
              Produto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao recuperar produtos: $e');
      return []; // Retornando uma lista vazia em caso de erro
    }
  }
}
