import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/Note.dart';
import 'NoteDetailScreen.dart';

// Widget hiển thị từng ghi chú trong danh sách
class NoteListItem extends StatelessWidget {
  final Note note;
  final VoidCallback onDelete; // Callback khi xoá
  final VoidCallback onEdit;   // Callback khi sửa
  final VoidCallback? onTap;   // Callback khi nhấn vào ghi chú (tuỳ chọn)

  const NoteListItem({
    Key? key,
    required this.note,
    required this.onDelete,
    required this.onEdit,
    this.onTap,
  }) : super(key: key);

  // Hàm trả về màu nền theo mức độ ưu tiên
  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red.shade100; // Cao
      case 2:
        return Colors.orange.shade100; // Trung bình
      case 1:
      default:
        return Colors.green.shade100; // Thấp
    }
  }

  // Tự động chọn màu chữ (đen/trắng) theo độ sáng
  Color _textColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _priorityColor(note.priority);
    final textColor = _textColor(bgColor);

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // Avatar chữ cái đầu tiêu đề
        leading: CircleAvatar(
          backgroundColor: Colors.white,
          child: Text(
            note.title.isNotEmpty ? note.title[0].toUpperCase() : '?',
            style: TextStyle(color: bgColor, fontWeight: FontWeight.bold),
          ),
        ),

        // Tiêu đề & nội dung
        title: Text(
          note.title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          note.content.length > 50
              ? '${note.content.substring(0, 50)}...'
              : note.content,
          style: TextStyle(color: textColor.withAlpha(200)),
        ),

        // Nút chỉnh sửa và xoá
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              color: Colors.blue.shade700,
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red.shade700,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Xác nhận xoá'),
                    content: const Text('Bạn có chắc muốn xoá ghi chú này không?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Huỷ'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Xoá'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),

        onTap: onTap ??
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NoteDetailScreen(note: note),
                ),
              );
            },
      ),
    );
  }
}
