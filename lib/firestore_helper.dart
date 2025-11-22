import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/note_model.dart';

class FirestoreHelper {
  final noteRef = FirebaseFirestore.instance
      .collection('notes')
      .withConverter<NoteModel>(
        fromFirestore: (snapshot, _) {
          final data = snapshot.data()!;
          data['note_id'] = snapshot.id; // Add document ID to the data
          return NoteModel.fromJson(data);
        },
        toFirestore: (note, _) => note.toJson(),
      );

  // CREATE - Add a new note
  Future<String> addNote(NoteModel note) async {
    try {
      final docRef = await noteRef.add(note);
      return docRef.id;
    } catch (e) {
      print('Error adding note: $e');
      rethrow;
    }
  }

  // READ - Get all notes
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final dataSnapshot = await noteRef
          .orderBy('created_at', descending: true)
          .get();

      return dataSnapshot.docs.map((doc) {
        final noteData = doc.data();
        noteData.noteId = doc.id;
        return noteData;
      }).toList();
    } catch (e) {
      print('Error getting notes: $e');
      return [];
    }
  }

  // READ - Get a single note by ID
  Future<NoteModel?> getNoteById(String noteId) async {
    try {
      final docSnapshot = await noteRef.doc(noteId).get();
      if (docSnapshot.exists) {
        final note = docSnapshot.data();
        note!.noteId = docSnapshot.id;
        return note;
      }
      return null;
    } catch (e) {
      print('Error getting note: $e');
      return null;
    }
  }

  // UPDATE - Update an existing note
  Future<void> updateNote(NoteModel note) async {
    try {
      if (note.noteId == null) {
        throw Exception('Note ID cannot be null for update');
      }
      await noteRef.doc(note.noteId).update(note.toJson());
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  // DELETE - Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      await noteRef.doc(noteId).delete();
    } catch (e) {
      print('Error deleting note: $e');
      rethrow;
    }
  }

  // STREAM - Listen to real-time updates
  Stream<List<NoteModel>> getNoteStream() {
    return noteRef.orderBy('created_at', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final noteData = doc.data();
        noteData.noteId = doc.id;
        return noteData;
      }).toList();
    });
  }

  // Toggle pin status
  Future<void> togglePin(String noteId, bool currentPinStatus) async {
    try {
      await noteRef.doc(noteId).update({
        'pinned': !currentPinStatus,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling pin: $e');
      rethrow;
    }
  }

  // Get pinned notes
  Future<List<NoteModel>> getPinnedNotes() async {
    try {
      final dataSnapshot = await noteRef
          .where('pinned', isEqualTo: true)
          .orderBy('created_at', descending: true)
          .get();

      return dataSnapshot.docs.map((doc) {
        final noteData = doc.data();
        noteData.noteId = doc.id;
        return noteData;
      }).toList();
    } catch (e) {
      print('Error getting pinned notes: $e');
      return [];
    }
  }
}
