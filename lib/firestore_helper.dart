import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/note_model.dart';

class FirestoreHelper {
  final noteRef = FirebaseFirestore.instance
      .collection('notes')
      .withConverter<NoteModel>(
        fromFirestore: (snapshot, _) =>
            NoteModel.fromJson(snapshot.data()!),
        toFirestore: (note, _) => note.toJson(),
      );

  Future addNote(NoteModel note) async {
    await noteRef.add(note);
    await noteRef.doc(note.noteId).set(note);
  }

  Future<List<NoteModel>> getAllNotes() async {
    final dataSnapshot = await noteRef.get();
    final debug = dataSnapshot.docs.map((doc) => doc.data()).toList();
    print(debug);
    return dataSnapshot.docs.map((doc) => doc.data()).toList();
  }
}
