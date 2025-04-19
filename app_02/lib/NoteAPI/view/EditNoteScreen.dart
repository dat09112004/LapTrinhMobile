import 'package:flutter/material.dart';
import '../model/Note.dart';
import '../API/NoteAPIService.dart';
import 'NoteForm.dart';

// Màn hình chỉnh sửa ghi chú
class EditNoteScreen extends StatelessWidget {
  final Note note; // Ghi chú cần chỉnh sửa

  const EditNoteScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NoteForm(
      note: note, // Truyền ghi chú vào form để hiện dữ liệu

      // Hàm xử lý khi người dùng nhấn "Lưu"
      onSave: (updatedNote) async {
        await NoteAPIService.instance.updateNote(updatedNote); // Gọi API cập nhật
        Navigator.pop(context, true); // Trở về màn hình trước và báo thành công
      },
    );
  }
}