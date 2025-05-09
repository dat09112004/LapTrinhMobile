import 'package:flutter/material.dart';
import '../model/MyTask.dart';
import 'TaskDetailScreen.dart';

class TaskListItem extends StatelessWidget {
  final MyTask task;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onEdit,
    this.onTap,
  }) : super(key: key);

  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red.shade50;
      case 2:
        return Colors.orange.shade50;
      default:
        return Colors.green.shade50;
    }
  }

  Color _iconBackgroundColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red.withOpacity(0.15);
      case 2:
        return Colors.orange.withOpacity(0.15);
      default:
        return Colors.green.withOpacity(0.15);
    }
  }

  Color _iconColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red.shade700;
      case 2:
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _priorityColor(task.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap ??
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _iconBackgroundColor(task.priority),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.task_alt,
                    color: _iconColor(task.priority),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description.length > 60
                            ? '${task.description.substring(0, 60)}...'
                            : task.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.dueDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.indigo,
                      onPressed: onEdit,
                      tooltip: "Chỉnh sửa",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red.shade700,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Xác nhận xoá'),
                            content: const Text('Bạn có chắc muốn xoá công việc này không?'),
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
                      tooltip: "Xoá",
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
