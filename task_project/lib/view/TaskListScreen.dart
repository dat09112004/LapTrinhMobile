import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/MyTask.dart';
import '../api/TaskAPIService.dart';
import 'TaskForm.dart';
import 'TaskLoginScreen.dart';
import 'TaskDetailScreen.dart';
import 'TaskListItem.dart';
import 'UserProfileScreen.dart';

class TaskListScreen extends StatefulWidget {
  final Function? onLogout;

  const TaskListScreen({this.onLogout, Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<MyTask>> _tasksFuture;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedTaskIds = {};
  List<MyTask> _allTasks = [];
  bool _selectionMode = false;
  String? _userId;
  String? _username;

  String _selectedStatus = 'Tất cả';
  int? _selectedPriority;

  final List<String> _statusOptions = [
    'Tất cả', 'To do', 'In progress', 'Done', 'Cancelled'
  ];

  final Map<int, String> _priorityLabels = {
    1: 'Thấp',
    2: 'Trung bình',
    3: 'Cao',
  };

  @override
  void initState() {
    super.initState();
    _tasksFuture = Future.value([]);
    _loadUserAndRefresh();
  }

  // Hàm tải thông tin người dùng từ SharedPreferences và làm mới danh sách công việc
  Future<void> _loadUserAndRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('accountId');
    _username = prefs.getString('username');
    if (mounted) {
      _refreshTasks();
    }
  }

  // Hàm làm mới danh sách công việc, áp dụng bộ lọc và xóa các lựa chọn
  void _refreshTasks() {
    if (_userId != null) {
      setState(() {
        _selectedStatus = 'Tất cả';
        _selectedPriority = null;
        _searchController.clear();

        _tasksFuture = TaskAPIService.instance.getTasksByUser(_userId!).then((tasks) {
          _allTasks = tasks;
          return _applyFilters('');
        });

        _selectedTaskIds.clear();
        _selectionMode = false;
      });
    } else {
      _tasksFuture = Future.value([]);
    }
  }

  // Hàm áp dụng bộ lọc tìm kiếm theo tiêu chí
  List<MyTask> _applyFilters(String query) {
    final lowerQuery = query.toLowerCase();
    return _allTasks.where((task) {
      final matchesText = task.title.toLowerCase().contains(lowerQuery) ||
          task.description.toLowerCase().contains(lowerQuery);

      final matchesStatus = _selectedStatus == 'Tất cả' ||
          task.status.toLowerCase() == _selectedStatus.toLowerCase();

      final matchesPriority = _selectedPriority == null ||
          task.priority == _selectedPriority;

      return matchesText && matchesStatus && matchesPriority;
    }).toList()
      ..sort((a, b) => b.priority.compareTo(a.priority));
  }

  // Hàm thay đổi chế độ chọn công việc
  void _toggleSelection(String taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
        if (_selectedTaskIds.isEmpty) _selectionMode = false;
      } else {
        _selectedTaskIds.add(taskId);
        _selectionMode = true;
      }
    });
  }

  // Hàm xóa các công việc đã chọn
  void _deleteSelectedTasks() async {
    for (final id in _selectedTaskIds) {
      try {
        await TaskAPIService.instance.deleteTask(id);
      } catch (e) {
        print("Error deleting task $id: $e");
      }
    }
    _refreshTasks();
  }

  // Hàm xử lý đăng xuất
  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TaskLoginScreen()),
            (route) => false,
      );
    }
  }

  // Hàm hiển thị hộp thoại xác nhận đăng xuất
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.lightBlue.shade200, Colors.white], // Nền sáng hơn, rõ ràng
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectionMode
                          ? 'Đã chọn: ${_selectedTaskIds.length}'
                          : 'Xin chào, ${_username ?? 'người dùng'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    Row(
                      children: [
                        if (_selectionMode)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: _deleteSelectedTasks,
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                            onPressed: _refreshTasks,
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'account') {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (_) => const UserProfileScreen(),
                                ));
                              } else if (value == 'logout') {
                                _showLogoutDialog();
                              }
                            },
                            icon: const Icon(Icons.more_vert, color: Colors.blueAccent),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'account',
                                child: ListTile(
                                  leading: Icon(Icons.account_circle),
                                  title: Text('Thông tin tài khoản'),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'logout',
                                child: ListTile(
                                  leading: Icon(Icons.logout, color: Colors.redAccent),
                                  title: Text('Đăng xuất'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Filters and Search
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Nền trắng rõ ràng cho phần filter
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.black87),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText: 'Tìm kiếm công việc...',
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.blueAccent),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _tasksFuture = Future.value(_applyFilters(''));
                              });
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blueAccent),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _tasksFuture = Future.value(_applyFilters(value));
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                labelText: 'Trạng thái',
                                labelStyle: const TextStyle(color: Colors.redAccent, fontSize: 26),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.black)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blueAccent),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              items: _statusOptions.map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status, style: const TextStyle(color: Colors.black87)),
                              )).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                  _tasksFuture = Future.value(_applyFilters(_searchController.text));
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int?>(
                              value: _selectedPriority,
                              style: const TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                labelText: 'Ưu tiên',
                                labelStyle: const TextStyle(color: Colors.redAccent,fontSize: 26),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.black)
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blueAccent),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Tất cả', style: TextStyle(color: Colors.black87)),
                                ),
                                ..._priorityLabels.entries.map((entry) => DropdownMenuItem<int?>(
                                  value: entry.key,
                                  child: Text(entry.value, style: const TextStyle(color: Colors.black87)),
                                )),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value;
                                  _tasksFuture = Future.value(_applyFilters(_searchController.text));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Task List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white, // Nền trắng cho danh sách task
                  ),
                  child: FutureBuilder<List<MyTask>>(
                    future: _tasksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.black87)));
                      }
                      final tasks = snapshot.data ?? [];
                      if (tasks.isEmpty && _userId != null) {
                        return const Center(child: Text('Không có công việc nào.', style: TextStyle(color: Colors.black87)));
                      }
                      if (tasks.isEmpty && _userId == null) {
                        return const Center(child: Text('Vui lòng đăng nhập.', style: TextStyle(color: Colors.black87)));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final isSelected = _selectedTaskIds.contains(task.id);
                          return GestureDetector(
                            onLongPress: () => _toggleSelection(task.id),
                            child: Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              color: isSelected ? Colors.blue.shade200 : Colors.white,
                              child: TaskListItem(
                                task: task,
                                onEdit: () async {
                                  final updatedTask = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TaskForm(
                                        task: task,
                                        onSave: (task) async {
                                          await TaskAPIService.instance.updateTask(task);
                                          if (mounted) Navigator.pop(context, task);
                                        },
                                      ),
                                    ),
                                  );
                                  if (updatedTask != null && mounted) _refreshTasks();
                                },
                                onDelete: () async {
                                  try {
                                    await TaskAPIService.instance.deleteTask(task.id);
                                    _refreshTasks();
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Xóa thất bại'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                onTap: () {
                                  if (_selectionMode) {
                                    _toggleSelection(task.id);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailScreen(task: task),
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
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectionMode
          ? null
          : FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () async {
          final newTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskForm(
                onSave: (task) async {
                  await TaskAPIService.instance.createTask(task);
                  if (mounted) _refreshTasks();
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
