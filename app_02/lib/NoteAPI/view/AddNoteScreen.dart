import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../APi/NoteAPIService.dart';
import 'NoteForm.dart';

class AddNoteScreen extends StatelessWidget {
  const AddNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoteForm(
      onSave: (note) async {
        await NoteAPIService.instance.createNote(note);
        Navigator.pop(context, true);
      },
    );
  }
}