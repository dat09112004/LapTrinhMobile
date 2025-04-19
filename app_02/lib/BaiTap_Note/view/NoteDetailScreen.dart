import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Note.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    final Color bgColor = note.color != null ? _parseColor(note.color!) : Colors.white;
    final Color textColor = _getContrastingTextColor(bgColor);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết ghi chú'),
        backgroundColor: bgColor,
        foregroundColor: textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // Tiêu đề
              Text(
                note.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),

              // Ngày tạo
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: textColor.withAlpha(180)),
                  const SizedBox(width: 8),
                  Text(
                    'Tạo lúc: ${formatter.format(note.createdAt)}',
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Ngày cập nhật
              Row(
                children: [
                  Icon(Icons.update, size: 18, color: textColor.withAlpha(180)),
                  const SizedBox(width: 8),
                  Text(
                    'Cập nhật: ${formatter.format(note.modifiedAt)}',
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mức độ ưu tiên
              Row(
                children: [
                  Icon(Icons.priority_high, size: 18, color: textColor.withAlpha(180)),
                  const SizedBox(width: 8),
                  Text(
                    'Ưu tiên: ${_priorityText(note.priority)}',
                    style: TextStyle(
                      color: _priorityColor(note.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Nội dung
              Text(
                note.content,
                style: TextStyle(fontSize: 16, color: textColor),
              ),
              const SizedBox(height: 20),

              // Tags
              if (note.tags != null && note.tags!.isNotEmpty) ...[
                Text(
                  'Nhãn:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: note.tags!
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.white.withAlpha(200),
                  ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Text mức độ ưu tiên
  String _priorityText(int value) {
    switch (value) {
      case 1:
        return 'Thấp';
      case 2:
        return 'Trung bình';
      case 3:
      default:
        return 'Cao';
    }
  }

  // Màu mức độ ưu tiên
  Color _priorityColor(int value) {
    switch (value) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
      default:
        return Colors.green;
    }
  }

  // Parse chuỗi màu thành Color
  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        final hex = colorStr.replaceAll('#', '');
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex')); // FF = full alpha
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
      } else {
        return Colors.primaries.firstWhere(
              (c) => c.toString().toLowerCase().contains(colorStr.toLowerCase()),
          orElse: () => Colors.grey,
        );
      }
    } catch (_) {
      return Colors.grey;
    }

    // Phòng trường hợp không rơi vào nhánh nào
    return Colors.grey;
  }

  // Màu chữ tương phản
  Color _getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
