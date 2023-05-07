import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Database handler class
class DatabaseWrapper {
  static final DatabaseWrapper _databaseWrapper = DatabaseWrapper._internal();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _subscriptions = List.empty(growable: true);

  //DatabaseWrapper() : _db = FirebaseFirestore.instance;

  factory DatabaseWrapper() {
    return _databaseWrapper;
  }

  DatabaseWrapper._internal();

  /// Stores [data] into the specified [collection] within the database
  /// Returns a future containing the ID of the newly added document
  Future<String> addDocument(
      String collection, Map<String, dynamic> data) async {
    DocumentReference ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  Future<void> addDocumentWithID(
      String collection, String documentID, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(documentID).set(data);
    return;
  }

  /// Updates an existing document within [collection] with an identifier matching [documentID]
  /// [data] should take the form {fieldToUpdate: updatedValue}
  Future<void> updateDocument(
      String collection, String documentID, Map<String, dynamic> data) async {
    return await _db.collection(collection).doc(documentID).update(data);
  }

  Future<Map<String, dynamic>?> getDocument(
      String collection, String documentID) async {
    DocumentSnapshot snapshot =
        await _db.collection(collection).doc(documentID).get();
    if (!snapshot.exists) return null;
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getDocumentsWhere(
      String collection, List<List<dynamic>> queries) async {
    Query ref = _db.collection(collection);
    for (var query in queries) {
      switch (query[1]) {
        case "==":
          ref = ref.where(query[0], isEqualTo: query[2]);
          break;
        case ">":
          ref = ref.where(query[0], isGreaterThan: query[2]);
          break;
      }
    }
    var docs = await ref.get();
    var results = List<Map<String, dynamic>>.empty();
    for (var doc in docs.docs) {
      results.add(doc.data() as Map<String, dynamic>);
    }
    return results;
  }

  StreamSubscription addListener(String collection, List<List<dynamic>> queries,
      Function(QuerySnapshot<Object?> event) callback) {
    Query ref = _db.collection(collection);
    for (var query in queries) {
      switch (query[1]) {
        case "==":
          ref = ref.where(query[0], isEqualTo: query[2]);
          break;
        case ">":
          ref = ref.where(query[0], isGreaterThan: query[2]);
          break;
      }
    }
    StreamSubscription sub = ref.snapshots().listen(callback);
    _subscriptions.add(sub);
    return sub;
  }

  Future<void> removeListener(StreamSubscription toRemove) async {
    _subscriptions.remove(toRemove);
    return toRemove.cancel();
  }

  Future<void> removeAllListeners() async {
    for (var sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();
    return;
  }

  DocumentReference getReferenceForDocument(
      String collection, String documentID) {
    return _db.collection(collection).doc(documentID);
  }
}
