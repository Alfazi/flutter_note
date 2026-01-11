import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_note/auth_helper.dart';
import 'package:flutter_note/firestore_helper.dart';
import 'package:flutter_note/models/note_model.dart';
import 'package:flutter_note/pages/note_editor_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteHomePage> {
  final FirestoreHelper firestoreHelper = FirestoreHelper();
  final AuthHelper authHelper = AuthHelper();

  List<NoteModel> _notes = [];
  bool _isLoading = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = authHelper.firebaseAuth.currentUser;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final noteList = await firestoreHelper.getAllNotes(_currentUser!.uid);
      setState(() {
        _notes = noteList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToCreateNote() async {
    // Navigate to create note page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditorPage()),
    );

    // Reload notes after returning from create page
    if (result != null) {
      _loadNotes();
    }
  }

  void _navigateToEditNote(NoteModel note) async {
    // Navigate to edit note page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditorPage(note: note)),
    );

    // Reload notes after returning from edit page
    if (result != null) {
      _loadNotes();
    }
  }

  void _deleteNote(String noteId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                await firestoreHelper.deleteNote(noteId);
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Note deleted')));
                }
                _loadNotes();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete note: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _togglePin(NoteModel note) async {
    try {
      await firestoreHelper.togglePin(note.noteId!, note.pinned);
      _loadNotes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle pin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        elevation: 0,
        actions: [
          // User email display
          if (_currentUser != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _currentUser!.email ?? 'User',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          // Sign out button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authHelper.signOutWithGoogle();
              if (mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/signin', (route) => false);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: Theme.of(context).primaryColor,
                size: 50.0,
              ),
            )
          : _notes.isEmpty
          ? _buildEmptyState()
          : _buildNoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNote,
        tooltip: 'Create new note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_add_outlined, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first note',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: IconButton(
              icon: Icon(
                note.pinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: note.pinned ? Colors.blue : Colors.grey,
              ),
              onPressed: () => _togglePin(note),
            ),
            title: Text(
              note.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(DateTime.parse(note.createdAt)),
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteNote(note.noteId!),
            ),
            onTap: () => _navigateToEditNote(note),
          ),
        );
      },
    );
  }
}
