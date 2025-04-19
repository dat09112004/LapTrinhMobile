import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../db/NoteDatabaseHelper.dart';
import 'NoteForm.dart';

// Màn hình chỉnh sửa ghi chú, nhận một Note cần chỉnh sửa
class EditNoteScreen extends StatelessWidget {
  final Note note;

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoteForm(
      note: note, // Truyền ghi chú cần chỉnh sửa vào form
      onSave: (updatedNote) async {
        // Khi người dùng nhấn lưu trên form
        await NoteDatabaseHelper.instance.updateNote(updatedNote); // Cập nhật vào DB
        Navigator.pop(context, true); // Trả về true để báo thành công và reload danh sách
      },
    );
  }
}
