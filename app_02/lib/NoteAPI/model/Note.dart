import 'dart:convert';

class Note {
  int? id; // ID ghi chú
  String title; // Tiêu đề
  String content; // Nội dung
  int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  DateTime createdAt; // Ngày tạo
  DateTime modifiedAt; // Ngày cập nhật
  List<String>? tags; // Nhãn
  String? color; // Màu sắc
  int userId; // Thêm userId để liên kết với người dùng

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
    required this.userId, // Bắt buộc truyền khi tạo note
  });

  Map<String, dynamic> toData() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','),
      'color': color,
      'userId': userId, // Thêm khi gửi lên API
    };
  }

  Map<String, dynamic> toMap() => toData();

  String toJSON() => jsonEncode(toData());

  factory Note.fromMap(Map<String, dynamic> map) {
    // Kiểm tra ngày tháng có hợp lệ không trước khi parse
    DateTime parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return DateTime.now(); // Nếu ngày rỗng, trả về ngày hiện tại
      try {
        return DateTime.parse(dateStr); // Thử parse nếu có thể
      } catch (e) {
        return DateTime.now(); // Nếu có lỗi, trả về ngày hiện tại
      }
    }

    return Note(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) : null, // An toàn với ID
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      priority: map['priority'] != null ? int.tryParse(map['priority'].toString()) ?? 0 : 0,
      createdAt: parseDate(map['createdAt']), // Dùng hàm parseDate để xử lý ngày tạo
      modifiedAt: parseDate(map['modifiedAt']), // Dùng hàm parseDate để xử lý ngày sửa
      tags: map['tags'] != null
          ? (map['tags'] is List
          ? List<String>.from(map['tags'])
          : List<String>.from((map['tags'] as String).split(',')))
          : null,
      color: map['color'] ?? '',
      userId: map['userId'] != null ? int.tryParse(map['userId'].toString()) ?? 0 : 0,
    );
  }

  factory Note.fromJSON(String json) => Note.fromMap(jsonDecode(json));

  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
    int? userId, // copy userId nếu cần
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      tags: tags ?? this.tags,
      color: color ?? this.color,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority, userId: $userId)';
  }
}
