import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/Note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;
  final Function(Note) onSave;

  const NoteForm({
    Key? key,
    this.note,
    required this.onSave,
  }) : super(key: key);

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _colorController = TextEditingController();
  int _priority = 2;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      final note = widget.note!;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _priority = note.priority;
      _tagsController.text = note.tags?.join(', ') ?? '';
      _colorController.text = note.color ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      final note = Note(
        id: widget.note?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        priority: _priority,
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        tags: _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
      );

      widget.onSave(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;
    final formatter = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Cập nhật Ghi chú' : 'Thêm Ghi chú'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'Mức độ ưu tiên',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Thấp')),
                  DropdownMenuItem(value: 2, child: Text('Trung bình')),
                  DropdownMenuItem(value: 3, child: Text('Cao')),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Màu sắc (hex hoặc tên)',
                  hintText: '#FF0000 hoặc blue',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Nhãn (tags cách nhau bằng dấu phẩy)',
                  hintText: 'công việc, cá nhân, học tập',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Hiển thị ngày tháng nếu đang sửa
              if (isEditing) ...[
                const Divider(),
                Text(
                  'Ngày tạo: ${formatter.format(widget.note!.createdAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cập nhật: ${formatter.format(widget.note!.modifiedAt)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
              ],

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(isEditing ? 'Cập nhật' : 'Thêm mới'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
