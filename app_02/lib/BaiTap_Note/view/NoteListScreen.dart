import 'package:flutter/material.dart';
import '../db/NoteDatabaseHelper.dart';
import '../model/Note.dart';
import 'package:app_02/BaiTap_Note/view/NoteForm.dart';
import 'NoteListItem.dart';
import 'NoteDetailScreen.dart';

class NoteListScreen extends StatefulWidget {
  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  late Future<List<Note>> _notesFuture;
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();


  // Hàm lấy danh sách ghi chú từ cơ sở dữ liệu
  void _refreshNotes() {
    setState(() {
      _notesFuture = NoteDatabaseHelper.instance.getAllNotes();
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý Note'),
        actions: [
          // Nút refresh thủ công
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshNotes,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus(); // Ẩn bàn phím
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      // Sử dụng FutureBuilder để xử lý dữ liệu bất đồng bộ
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Đang tải
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}')); // Lỗi
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có ghi chú')); // Không có dữ liệu
          }

          final notes = snapshot.data!;

          // Hiển thị danh sách ghi chú
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              // Dùng widget NoteListItem để hiển thị từng ghi chú
              return NoteListItem(
                note: note,

                // Khi chỉnh sửa ghi chú
                onEdit: () async {
                  final updatedNote = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NoteForm(
                        note: note,
                        onSave: (note) async {
                          await NoteDatabaseHelper.instance.updateNote(note);
                          Navigator.pop(context, note);
                        },
                      ),
                    ),
                  );
                  if (updatedNote != null) _refreshNotes();
                },

                // Khi xóa ghi chú
                onDelete: () async {
                  await NoteDatabaseHelper.instance.deleteNote(note.id!);
                  _refreshNotes();
                },

                // Khi nhấn vào ghi chú để xem chi tiết
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteDetailScreen(note: note),
                    ),
                  );
                },
              );
            },
          );
        },
      ),

      // Nút thêm ghi chú mới
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final newNote = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteForm(
                onSave: (note) async {
                  await NoteDatabaseHelper.instance.insertNote(note);
                  Navigator.pop(context, note);
                },
              ),
            ),
          );
          if (newNote != null) _refreshNotes(); // Làm mới danh sách nếu có ghi chú mới
        },
      ),
    );
  }
}
