import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_shiftsync/models/produtos.dart';

/// Cada usuário logado (uma empresa) tem seu próprio estoque, isolado dos
/// demais: os produtos ficam em `users/{uid}/produtos`, uma subcoleção por
/// conta, em vez de uma coleção única compartilhada por todo mundo.
class ProdutosRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Nenhum usuário autenticado.');
    }
    return _firestore.collection('users').doc(uid).collection('produtos');
  }

  Future<DocumentReference> addProduto(Produto produto) async {
    try {
      var docRef = await _collection.add(produto.toFirestore());
      return docRef;
    } catch (e) {
      print('Erro ao adicionar produto: $e');
      throw e;
    }
  }

  Future<List<Produto>> getProdutos() async {
    try {
      QuerySnapshot querySnapshot = await _collection.get();
      return querySnapshot.docs
          .map((doc) =>
              Produto.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Erro ao recuperar produtos: $e');
      return [];
    }
  }

  Future<void> deleteProduto(String id) async {
    await _collection.doc(id).delete();
  }

  Future<void> updateProdutoIcone(String id, String icone) async {
    await _collection.doc(id).update({'icone': icone});
  }

  Future<void> updateProduto(String id, Map<String, dynamic> data) async {
    await _collection.doc(id).update(data);
  }

  Future<void> setFavorito(String id, bool favorito) async {
    await _collection.doc(id).update({'favorito': favorito});
  }
}
