import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/User.dart';
import '../api/UserAPIService.dart';
import 'TaskListScreen.dart';
import 'TaskRegisterScreen.dart';

class TaskLoginScreen extends StatefulWidget {
  const TaskLoginScreen({super.key});

  @override
  _TaskLoginScreenState createState() => _TaskLoginScreenState();
}

class _TaskLoginScreenState extends State<TaskLoginScreen> {
  final _formKey = GlobalKey<FormState>(); // dùng để xác thực form
  final _usernameController = TextEditingController(); // controller cho ô nhập username
  final _passwordController = TextEditingController(); // controller cho ô nhập password
  bool _isLoading = false; // trạng thái đang xử lý đăng nhập
  bool _obscurePassword = true; // ẩn/hiện mật khẩu

  // hủy controller khi widget bị dispose
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // hiển thị loading

      try {
        final user = await UserAPIService.instance.login(
          _usernameController.text.trim(),
          _passwordController.text.trim(),
        );

        setState(() => _isLoading = false); // tắt loading

        if (user != null) {
          final prefs = await SharedPreferences.getInstance();
          // lưu thông tin tài khoản vào SharedPreferences
          await prefs.setString('accountId', user.id);
          await prefs.setString('username', user.username);
          await prefs.setString('role', user.role);
          await prefs.setBool('isLoggedIn', true);

          if (!mounted) return;

          // chuyển sang màn hình danh sách task sau khi đăng nhập thành công
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => TaskListScreen(onLogout: _logout),
            ),
          );
        } else {
          // nếu user null => sai tài khoản hoặc mật khẩu
          _showErrorDialog('Đăng nhập thất bại', 'Sai tài khoản hoặc mật khẩu.');
        }
      } catch (e) {
        setState(() => _isLoading = false); // tắt loading khi lỗi
        _showErrorDialog('Lỗi đăng nhập', 'Đã xảy ra lỗi: $e'); // hiển thị lỗi
      }
    }
  }

  // Hàm xử lý đăng xuất
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // xóa toàn bộ dữ liệu người dùng
    if (mounted) {
      // chuyển về màn hình đăng nhập
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const TaskLoginScreen()),
            (route) => false,
      );
    }
  }

  // Hiển thị hộp thoại báo lỗi
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  // Giao diện màn hình đăng nhập
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: _formKey, // gắn form key
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.task_alt, size: 80, color: Colors.green),
                  const SizedBox(height: 10),
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // ô nhập tên đăng nhập
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Tên đăng nhập',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập tên đăng nhập' : null,
                  ),
                  const SizedBox(height: 20),
                  // ô nhập mật khẩu
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Vui lòng nhập mật khẩu' : null,
                  ),
                  const SizedBox(height: 30),
                  // nút đăng nhập
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login, // gọi _login khi bấm
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // liên kết đến màn hình đăng ký
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TaskRegisterScreen()),
                      );
                    },
                    child: const Text(
                      "Bạn chưa có tài khoản? Đăng ký",
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
