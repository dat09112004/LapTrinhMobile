import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/AccountNote.dart';
import '../API/AccountNoteAPIService.dart';
import 'LoginScreenNote.dart';
import 'Background.dart';

class NoteRegisterScreen extends StatefulWidget {
  const NoteRegisterScreen({super.key});

  @override
  _NoteRegisterScreenState createState() => _NoteRegisterScreenState();
}

class _NoteRegisterScreenState extends State<NoteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // Kiểm tra username đã tồn tại
        final usernameExists = await AccountNoteAPIService.instance
            .isUsernameExists(_usernameController.text.trim());

        if (usernameExists) {
          setState(() => _isLoading = false);
          _showErrorDialog(
            'Lỗi đăng ký',
            'Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.',
          );
          return;
        }

        // Tính userId mới
        final accounts = await AccountNoteAPIService.instance.getAllAccounts();
        int newUserId = 3; // Bắt đầu từ 3
        if (accounts.isNotEmpty) {
          final maxUserId = accounts
              .map((account) => account.userId)
              .reduce((a, b) => a > b ? a : b);
          newUserId = maxUserId + 1; // Tăng dần từ userId lớn nhất
        }

        // Tạo account mới
        final newAccount = AccountNote(
          userId: newUserId,
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
          status: 'active',
          lastLogin: DateTime.now().toIso8601String(),
          createdAt: DateTime.now().toIso8601String(),
        );

        final createdAccount = await AccountNoteAPIService.instance
            .createAccount(newAccount);

        setState(() => _isLoading = false);

        if (!mounted) return;

        // Hiển thị thông báo thành công
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                title: const Text('Đăng ký thành công'),
                content: const Text(
                  'Tài khoản của bạn đã được tạo. Vui lòng đăng nhập để tiếp tục.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(
                        context,
                      ).pop(); // Quay lại màn hình đăng nhập
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorDialog('Lỗi đăng ký', 'Đã xảy ra lỗi: $e');
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký Note-API')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 40),

                // Tên đăng nhập
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên đăng nhập';
                    }
                    if (value.length < 4) {
                      return 'Tên đăng nhập phải có ít nhất 4 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Mật khẩu
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
                      onPressed:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Xác nhận mật khẩu
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed:
                          () => setState(
                            () =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                          ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Nút đăng ký
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'ĐĂNG KÝ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Đã có tài khoản? Đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
