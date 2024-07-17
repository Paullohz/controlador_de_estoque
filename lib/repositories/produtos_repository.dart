import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_shiftsync/models/produtos.dart';

class ProdutosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> addProduto(Produto produto) async {
    try {
      var docRef = await _firestore.collection('produtos').add(produto.toFirestore());
      return docRef;
    } catch (e) {
      print('Erro ao adicionar produto: $e');
      throw e;
    }
  }

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
      return [];
    }
  }

  final CollectionReference collection =
      FirebaseFirestore.instance.collection('produtos');

  Future<void> deleteProduto(String id) async {
    await collection.doc(id).delete();
  }
}
