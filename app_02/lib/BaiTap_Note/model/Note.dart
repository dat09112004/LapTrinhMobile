class Note {
  int? id; // ID ghi chú, tự tăng trong database
  String title; // Tiêu đề ghi chú
  String content; // Nội dung ghi chú
  int priority; // 1: Thấp, 2: Trung bình, 3: Cao
  DateTime createdAt; // Ngày giờ tạo ghi chú
  DateTime modifiedAt; // Ngày giờ chỉnh sửa lần cuối
  List<String>? tags; // Danh sách nhãn (tags) như "công việc", "cá nhân", ...
  String? color; // Màu sắc (mã hex hoặc tên màu)

  // Constructor chính để khởi tạo đối tượng Note
  Note({
    this.id,
    required this.title,
    required this.content,
    required this.priority,
    required this.createdAt,
    required this.modifiedAt,
    this.tags,
    this.color,
  });

  // Tạo đối tượng Note từ Map (dùng khi đọc từ SQLite)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      priority: map['priority'],
      createdAt: DateTime.parse(map['createdAt']),
      modifiedAt: DateTime.parse(map['modifiedAt']),
      tags: map['tags'] != null
          ? List<String>.from((map['tags'] as String).split(','))
          : null,
      color: map['color'],
    );
  }

  // Chuyển đối tượng Note thành Map (dùng khi ghi vào SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'tags': tags?.join(','), // Lưu tags dưới dạng chuỗi phân tách bởi dấu phẩy
      'color': color,
    };
  }

  // Tạo bản sao mới từ ghi chú hiện tại, cho phép thay đổi một số trường
  Note copyWith({
    int? id,
    String? title,
    String? content,
    int? priority,
    DateTime? createdAt,
    DateTime? modifiedAt,
    List<String>? tags,
    String? color,
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
    );
  }

  // Hàm toString giúp hiển thị thông tin Note khi debug
  @override
  String toString() {
    return 'Note(id: $id, title: $title, priority: $priority)';
  }
}
