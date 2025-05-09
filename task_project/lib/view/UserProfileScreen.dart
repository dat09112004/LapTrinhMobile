import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/User.dart';
import '../api/UserAPIService.dart';
import 'UserEditScreen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('accountId');
    if (id != null) {
      final user = await UserAPIService.instance.getUserById(id);
      setState(() {
        _user = user;
      });
    }
  }
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            if (_user!.avatar != null && _user!.avatar!.isNotEmpty)
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(_user!.avatar!),
              )
            else
              const CircleAvatar(
                radius: 60,
                child: Icon(Icons.person, size: 60),
              ),
            const SizedBox(height: 20),

            // Thông tin tài khoản
            _buildInfoTile(Icons.person, 'Tên đăng nhập', _user!.username),
            _buildInfoTile(Icons.email, 'Email', _user!.email),
            _buildInfoTile(Icons.calendar_today, 'Ngày tạo', _formatDate(_user!.createdAt)),

            const SizedBox(height: 30),

            // Nút chuyển trang đổi mật khẩu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text(
                  "Đổi mật khẩu",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UserEditScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
