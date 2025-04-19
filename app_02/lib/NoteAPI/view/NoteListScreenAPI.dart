import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/Note.dart';
import '../API/NoteAPIService.dart';
import 'NoteForm.dart';
import 'NoteListItem.dart';
import 'NoteDetailScreen.dart';
import 'LoginScreenNote.dart';

class NoteListScreenAPI extends StatefulWidget {
  final Function? onLogout;

  const NoteListScreenAPI({this.onLogout, Key? key}) : super(key: key);

  @override
  _NoteListScreenState createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreenAPI> {
  late Future<List<Note>> _notesFuture = Future.value([]);
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedNoteIds = {};
  bool _selectionMode = false;
  int? _userId;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserAndRefresh();
  }

  Future<void> _loadUserAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    final username = prefs.getString('username'); // lấy username

    setState(() {
      _userId = userId;
      _username = username;
    });

    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      if (_userId != null) {
        _notesFuture = NoteAPIService.instance.getNotesByUser(_userId!);
      } else {
        _notesFuture = Future.value([]);
      }
      _selectedNoteIds.clear();
      _selectionMode = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(int noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        if (_selectedNoteIds.isEmpty) _selectionMode = false;
      } else {
        _selectedNoteIds.add(noteId);
        _selectionMode = true;
      }
    });
  }

  void _deleteSelectedNotes() async {
    for (final id in _selectedNoteIds) {
      await NoteAPIService.instance.deleteNote(id);
    }
    _refreshNotes();
  }

  Future<void> _handleLogout() async {
    // Xóa dữ liệu người dùng
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Kiểm tra xem widget có còn được gắn kết không
    if (!mounted) return;

    // Điều hướng trở lại màn hình đăng nhập và xóa tất cả các màn hình trước đó
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreenNote()),
      (Route<dynamic> route) => false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Xác nhận đăng xuất'),
            content: Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _handleLogout();
                },
                child: Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectionMode
              ? 'Đã chọn: ${_selectedNoteIds.length}'
              : 'Xin chào, ${_username ?? 'người dùng'}',
        ),
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSelectedNotes,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshNotes,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') _showLogoutDialog();
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Đăng xuất'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
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
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            FocusScope.of(context).unfocus();
                            _refreshNotes();
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
              onChanged: (value) async {
                if (_userId != null) {
                  try {
                    final results = await NoteAPIService.instance.searchNotes(
                      value,
                      userId: _userId!,
                    );
                    setState(() {
                      _notesFuture = Future.value(results);
                    });
                  } catch (e) {
                    print('Search error: $e');
                  }
                }
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có ghi chú'));
          }

          final notes = snapshot.data!;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              final isSelected = _selectedNoteIds.contains(note.id);

              return GestureDetector(
                onLongPress: () => _toggleSelection(note.id!),
                child: Container(
                  color: isSelected ? Colors.grey[300] : null,
                  child: NoteListItem(
                    note: note,
                    onEdit: () async {
                      final updatedNote = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => NoteForm(
                                note: note,
                                onSave: (note) async {
                                  await NoteAPIService.instance.updateNote(
                                    note,
                                  );
                                  Navigator.pop(context, note);
                                },
                              ),
                        ),
                      );
                      if (updatedNote != null) _refreshNotes();
                    },
                    onDelete: () async {
                      await NoteAPIService.instance.deleteNote(note.id!);
                      _refreshNotes();
                    },
                    onTap: () {
                      if (_selectionMode) {
                        _toggleSelection(note.id!);
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailScreen(note: note),
                          ),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          _selectionMode
              ? null
              : FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getInt('userId');

                  if (userId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không xác định được tài khoản')),
                    );
                    return;
                  }

                  final newNote = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => NoteForm(
                            onSave: (note) async {
                              final noteWithUser = note.copyWith(
                                userId: userId,
                              );
                              await NoteAPIService.instance.createNote(
                                noteWithUser,
                              );
                              Navigator.pop(context, noteWithUser);
                            },
                          ),
                    ),
                  );
                  if (newNote != null) _refreshNotes();
                },
              ),
    );
  }
}
