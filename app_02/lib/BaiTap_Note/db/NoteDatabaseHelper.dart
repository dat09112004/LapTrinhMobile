import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/Note.dart';

class NoteDatabaseHelper {
  // Tạo Singleton để chỉ có một instance duy nhất trong toàn app
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  // Trả về instance database đã khởi tạo hoặc khởi tạo mới nếu chưa có
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('note_database.db');
    return _database!;
  }

  // Hàm khởi tạo database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // Lấy đường dẫn tới thư mục chứa database
    final path = join(dbPath, filePath);     // Nối đường dẫn với tên file

    return await openDatabase(path, version: 1, onCreate: _createDB); // Mở hoặc tạo mới DB
  }

  // Tạo bảng notes khi DB được khởi tạo lần đầu
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
    ''');

    // Chèn dữ liệu mẫu vào bảng notes
    await _insertSampleNotes(db);
  }

  // Hàm thêm dữ liệu mẫu ban đầu để test ứng dụng
  Future<void> _insertSampleNotes(Database db) async {
    final now = DateTime.now();

    final List<Map<String, dynamic>> sampleNotes = [
      {
        'title': 'Mua sắm cuối tuần',
        'content': 'Mua rau, thịt, sữa và mì gói.',
        'priority': 2,
        'createdAt': now.toIso8601String(),
        'modifiedAt': now.toIso8601String(),
        'tags': 'cá nhân,mua sắm',
        'color': '#FFEB3B',
      },
      {
        'title': 'Học Flutter',
        'content': 'Xem lại phần SQLite và UI Form.',
        'priority': 3,
        'createdAt': now.toIso8601String(),
        'modifiedAt': now.toIso8601String(),
        'tags': 'học tập,flutter',
        'color': '#8BC34A',
      },
      {
        'title': 'Cuộc họp với nhóm',
        'content': 'Thảo luận tiến độ dự án Note App.',
        'priority': 1,
        'createdAt': now.toIso8601String(),
        'modifiedAt': now.toIso8601String(),
        'tags': 'dự án,nhóm',
        'color': '#03A9F4',
      },
    ];

    // Thêm từng ghi chú mẫu vào bảng
    for (final note in sampleNotes) {
      await db.insert('notes', note);
    }
  }

  // Thêm ghi chú mới
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Lấy tất cả ghi chú
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Lấy ghi chú theo ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final result = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Note.fromMap(result.first);
    }
    return null;
  }

  // Cập nhật ghi chú
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    return await db.update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  // Xóa ghi chú theo ID
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Lấy các ghi chú theo mức độ ưu tiên
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await instance.database;
    final result = await db.query('notes', where: 'priority = ?', whereArgs: [priority]);
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Tìm kiếm ghi chú theo từ khóa trong tiêu đề hoặc nội dung
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Đóng kết nối database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
