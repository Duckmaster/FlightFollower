import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Database handler class
class DatabaseWrapper extends ChangeNotifier {
  final FirebaseFirestore _db;
  DatabaseWrapper() : _db = FirebaseFirestore.instance;

  /// Stores [data] into the specified [collection] within the database
  /// Returns a future containing the ID of the newly added document
  Future<String> addDocument(
      String collection, Map<String, dynamic> data) async {
    DocumentReference ref = await _db.collection(collection).add(data);
    return ref.id;
  }

  /// Updates an existing document within [collection] with an identifier matching [documentID]
  /// [data] should take the form {fieldToUpdate: updatedValue}
  Future<void> updateDocument(
      String collection, String documentID, Map<String, dynamic> data) async {
    return await _db.collection(collection).doc(documentID).update(data);
  }
}
