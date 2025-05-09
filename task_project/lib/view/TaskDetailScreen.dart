import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/MyTask.dart';
import '../model/User.dart';
import '../api/UserAPIService.dart';

class TaskDetailScreen extends StatefulWidget {
  final MyTask task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  User? creator;
  User? assignee;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final c = await UserAPIService.instance.getUserById(widget.task.createdBy);
    final a = widget.task.assignedTo != null
        ? await UserAPIService.instance.getUserById(widget.task.assignedTo!)
        : null;

    setState(() {
      creator = c;
      assignee = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        backgroundColor: Colors.teal.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(task),
                const SizedBox(height: 16),
                _chips(task),
                const SizedBox(height: 16),
                _infoRow(Icons.calendar_today, 'Tạo lúc: ${formatter.format(task.createdAt)}'),
                _infoRow(Icons.update, 'Cập nhật: ${formatter.format(task.updatedAt)}'),
                if (task.dueDate != null)
                  _infoRow(Icons.event, 'Hạn chót: ${formatter.format(task.dueDate!)}'),
                _infoRow(
                  Icons.check_circle_outline,
                  'Hoàn thành: ${task.completed ? "✔ Có" : "✘ Chưa"}',
                  color: task.completed ? Colors.green : Colors.grey,
                ),
                const Divider(height: 32),
                _sectionTitle('Mô tả'),
                Text(
                  task.description.isNotEmpty ? task.description : 'Không có mô tả',
                  style: const TextStyle(fontSize: 15),
                ),
                const Divider(height: 32),
                _sectionTitle('Thông tin người dùng'),
                _infoRow(Icons.person, 'Người tạo: ${creator?.username ?? "Đang tải..."}'),
                _infoRow(Icons.person_pin, 'Giao cho: ${assignee?.username ?? "Chưa có"}'),
                if (task.attachments != null && task.attachments!.isNotEmpty) ...[
                  const Divider(height: 32),
                  _sectionTitle('Tệp đính kèm'),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: task.attachments!
                        .map((file) => Row(
                      children: [
                        const Icon(Icons.attach_file, size: 18, color: Colors.teal),
                        const SizedBox(width: 4),
                        Expanded(child: Text(file, style: const TextStyle(fontSize: 14))),
                      ],
                    ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(MyTask task) => Row(
    children: [
      Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.teal.shade50,
        ),
        padding: const EdgeInsets.all(12),
        child: const Icon(Icons.task_alt, size: 28, color: Colors.teal),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(task.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    ],
  );

  Widget _chips(MyTask task) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      Chip(
        avatar: const Icon(Icons.info, size: 18, color: Colors.white),
        backgroundColor: _statusColor(task.status),
        label: Text(task.status.toUpperCase(), style: const TextStyle(color: Colors.white)),
      ),
      Chip(
        avatar: const Icon(Icons.priority_high, size: 18, color: Colors.white),
        backgroundColor: _priorityColor(task.priority),
        label: Text(_priorityText(task.priority), style: const TextStyle(color: Colors.white)),
      ),
      if (task.category != null && task.category!.isNotEmpty)
        Chip(label: Text(task.category!), backgroundColor: Colors.blueGrey.shade50),
    ],
  );

  Widget _infoRow(IconData icon, String text, {Color? color}) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 15, color: color ?? Colors.black87)),
        ),
      ],
    ),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );

  String _priorityText(int value) => value == 1 ? 'Thấp' : value == 2 ? 'Trung bình' : 'Cao';

  Color _priorityColor(int value) =>
      value == 3 ? Colors.red.shade400 : value == 2 ? Colors.orange.shade400 : Colors.green.shade400;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'done':
        return Colors.green.shade400;
      case 'in progress':
        return Colors.blue.shade400;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange.shade400;
    }
  }
}
