import 'package:flutter/material.dart';
import '../../model/User.dart';
import '../../api/UserAPIService.dart';
import 'TaskLoginScreen.dart';

class TaskRegisterScreen extends StatefulWidget {
  const TaskRegisterScreen({Key? key}) : super(key: key);

  @override
  State<TaskRegisterScreen> createState() => _TaskRegisterScreenState();
}

class _TaskRegisterScreenState extends State<TaskRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;
  bool _obscurePassword = true;

  // Hàm đăng ký tài khoản người dùng mới
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      // Lấy danh sách tất cả user để kiểm tra trùng username/email
      final allUsers = await UserAPIService.instance.getAllUsers();

      // Kiểm tra tên đăng nhập hoặc email đã tồn tại chưa
      final isTaken = allUsers.any((u) =>
      u.username.trim().toLowerCase() == _usernameController.text.trim().toLowerCase() ||
          u.email.trim().toLowerCase() == _emailController.text.trim().toLowerCase());

      if (isTaken) {
        setState(() {
          _error = "Tên đăng nhập hoặc email đã được sử dụng.";
          _isLoading = false;
        });
        return;
      }

      // Tính ID tiếp theo dựa trên ID lớn nhất trong danh sách
      int nextId = 20;
      if (allUsers.isNotEmpty) {
        final maxId = allUsers.map((u) => int.tryParse(u.id) ?? 0).reduce((a, b) => a > b ? a : b);
        nextId = maxId + 1;
      }

      // Tạo đối tượng người dùng mới
      final newUser = User(
        id: nextId.toString(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
        role: 'user',
      );

      // Gửi yêu cầu tạo người dùng đến API
      await UserAPIService.instance.createUser(newUser);

      // Cập nhật thông báo thành công và chuyển sang màn hình đăng nhập
      setState(() {
        _success = "Đăng ký thành công! Vui lòng đăng nhập.";
      });

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TaskLoginScreen()),
        );
      }
    } catch (e) {
      // Nếu có lỗi xảy ra trong quá trình đăng ký
      setState(() {
        _error = "Đăng ký thất bại: $e";
      });
    } finally {
      // Dù thành công hay thất bại đều tắt loading
      setState(() => _isLoading = false);
    }
  }

  // Giao diện màn hình đăng ký
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.task_alt, size: 72, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'Tạo tài khoản',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập tên đăng nhập';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Email không hợp lệ';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
                          if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_error != null)
                        Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                      if (_success != null)
                        Text(_success!, style: const TextStyle(color: Colors.green), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register, // Gọi hàm đăng ký
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ĐĂNG KÝ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const TaskLoginScreen()), // Chuyển về màn hình đăng nhập
                          );
                        },
                        child: const Text(
                          'Đã có tài khoản? Đăng nhập ngay',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
