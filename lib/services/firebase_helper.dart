import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight Firestore helper for basic CRUD operations and streams.
/// Usage:
/// final db = FirebaseHelper.instance;
/// await db.add('notes', {'text': 'hello'});
class FirebaseHelper {
  FirebaseHelper._();
  static FirebaseHelper? _instance;

  static FirebaseHelper get instance {
    _instance ??= FirebaseHelper._();
    return _instance!;
  }

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String path) => _db
      .collection(path)
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snap, _) => snap.data() ?? {},
        toFirestore: (obj, _) => obj,
      );

  // Add a document with auto-ID
  Future<DocumentReference<Map<String, dynamic>>> add(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    final docData = Map<String, dynamic>.from(data);
    docData['createdAt'] = FieldValue.serverTimestamp();
    return _col(collectionPath).add(docData);
  }

  // Set (create/replace) a document by id. Use merge=true to merge fields.
  Future<void> set(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    final docRef = _col(collectionPath).doc();
    return docRef.set(data, SetOptions(merge: merge));
  }

  // Update specific fields of a document
  Future<void> update(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _col(collectionPath).doc(docId).update(data);
  }

  // Delete a document
  Future<void> delete(String collectionPath, String docId) {
    return _col(collectionPath).doc(docId).delete();
  }

  // Get a single document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDoc(
    String collectionPath,
    String docId,
  ) {
    return _col(collectionPath).doc(docId).get();
  }

  // Get all documents (optionally with limit and ordering)
  // Returns a list of maps (each includes the document id under key 'id').
  Future<List<Map<String, dynamic>>> getCollection(
    String collectionPath, {
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    Query<Map<String, dynamic>> q = _col(collectionPath);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    if (limit != null) q = q.limit(limit);
    final snapshot = await q.get();
    return snapshot.docs.map((d) => docDataWithId(d)).toList();
  }

  // Stream of documents for a collection (useful for UI)
  Stream<QuerySnapshot<Map<String, dynamic>>> streamCollection(
    String collectionPath, {
    String? orderBy,
    bool descending = false,
  }) {
    Query<Map<String, dynamic>> q = _col(collectionPath);
    if (orderBy != null) q = q.orderBy(orderBy, descending: descending);
    return q.snapshots();
  }

  // Stream a single document
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamDocument(
    String collectionPath,
    String docId,
  ) {
    return _col(collectionPath).doc(docId).snapshots();
  }

  // Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) {
    return _db.runTransaction<T>(transactionHandler);
  }

  // Perform a batched write
  Future<void> runBatch(void Function(WriteBatch batch) batchUpdater) async {
    final batch = _db.batch();
    batchUpdater(batch);
    await batch.commit();
  }

  // Convenience: convert DocumentSnapshot to map with id included
  static Map<String, dynamic> docDataWithId(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? <String, dynamic>{};
    return {'id': snap.id, ...data};
  }

  // Delete all documents in a collection using batched writes.
  // Warning: this permanently removes all documents in the collection.
  Future<void> deleteAllDocuments(
    String collectionPath, {
    int batchSize = 500,
  }) async {
    final coll = _col(collectionPath);
    while (true) {
      final snapshot = await coll.limit(batchSize).get();
      final docs = snapshot.docs;
      if (docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
