import 'package:flutter/material.dart';
import '../model/MyTask.dart';
import '../api/UserAPIService.dart';
import '../model/User.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class TaskForm extends StatefulWidget {
  final MyTask? task;
  final Function(MyTask) onSave;

  const TaskForm({super.key, this.task, required this.onSave});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _attachmentsController = TextEditingController();

  final _statusList = ['OPEN', 'IN PROGRESS', 'DONE', 'COMPLETE'];
  final _priorityList = [3, 2, 1];

  DateTime? _dueDate;
  String _selectedStatus = 'OPEN';
  int _selectedPriority = 2;
  String? _assignedTo;
  bool _isCompleted = false;

  List<User> _userList = [];
  String? _currentUserId;
  String? _currentUserRole;

  final Color primaryColor = const Color(0xFF4DB6AC);
  final Color highlightTextColor = const Color(0xFF00796B);
  final Color inputFillColor = const Color(0xFFF1F8F6);
  final Color buttonColor = const Color(0xFF00897B);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentUserId = prefs.getString('accountId');
    _currentUserRole = prefs.getString('role') ?? 'user';

    final allUsers = await UserAPIService.instance.getAllUsers();
    setState(() {
      _userList = allUsers.where((u) => u.role == 'user').toList();

      if (widget.task != null) {
        final t = widget.task!;
        _titleController.text = t.title;
        _descriptionController.text = t.description;
        _categoryController.text = t.category ?? '';
        _attachmentsController.text = t.attachments?.join(',') ?? '';
        _selectedStatus = t.status;
        _selectedPriority = t.priority;
        _dueDate = t.dueDate;
        _assignedTo = t.assignedTo;
        _isCompleted = t.completed;
      } else {
        _assignedTo = _currentUserRole == 'admin' ? null : _currentUserId;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _attachmentsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final random = Random();
    final now = DateTime.now();
    final task = MyTask(
      id: widget.task?.id ?? (100 + random.nextInt(999999)).toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      dueDate: _dueDate,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
      createdBy: widget.task?.createdBy ?? _currentUserId!,
      assignedTo: _currentUserRole == 'admin' ? _assignedTo : _currentUserId,
      category: _categoryController.text.trim(),
      attachments: _attachmentsController.text.trim().split(','),
      completed: _isCompleted,
    );

    widget.onSave(task);
    Navigator.pop(context, task);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: highlightTextColor),
      labelStyle: TextStyle(color: highlightTextColor),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: inputFillColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa công việc' : 'Tạo công việc mới'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Tiêu đề', Icons.title),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Mô tả', Icons.description),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: _statusList.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
                decoration: _inputDecoration('Trạng thái', Icons.flag),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<int>(
                value: _selectedPriority,
                items: _priorityList.map((level) {
                  String text;
                  switch (level) {
                    case 3:
                      text = 'Cao';
                      break;
                    case 2:
                      text = 'Trung bình';
                      break;
                    case 1:
                      text = 'Thấp';
                      break;
                    default:
                      text = 'Không xác định';
                  }
                  return DropdownMenuItem(
                    value: level,
                    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedPriority = val!),
                decoration: _inputDecoration('Độ ưu tiên', Icons.priority_high),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecoration('Phân loại', Icons.category),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _attachmentsController,
                decoration: _inputDecoration('Tệp đính kèm (phân tách bằng dấu phẩy)', Icons.attachment),
              ),
              const SizedBox(height: 14),
              _currentUserRole == 'admin'
                  ? DropdownButtonFormField<String>(
                value: _assignedTo,
                items: _userList
                    .map((u) =>
                    DropdownMenuItem(value: u.id, child: Text(u.username)))
                    .toList(),
                onChanged: (val) => setState(() => _assignedTo = val),
                decoration: _inputDecoration('Giao cho', Icons.person_add),
              )
                  : ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person, color: highlightTextColor),
                title: Text(
                  'Giao cho: bạn (${_currentUserId ?? "Không xác định"})',
                  style: TextStyle(color: highlightTextColor),
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: inputFillColor,
                leading: Icon(Icons.calendar_today, color: highlightTextColor),
                title: Text(
                  _dueDate == null
                      ? 'Chọn hạn chót'
                      : 'Hạn chót: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                  style: TextStyle(color: highlightTextColor),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                title: const Text('Đánh dấu là hoàn thành'),
                value: _isCompleted,
                activeColor: buttonColor,
                onChanged: (val) => setState(() => _isCompleted = val ?? false),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(isEdit ? Icons.save : Icons.add, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                label: Text(
                  isEdit ? 'Cập nhật' : 'Tạo mới',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
