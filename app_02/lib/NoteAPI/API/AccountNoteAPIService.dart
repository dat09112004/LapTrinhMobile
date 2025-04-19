import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/AccountNote.dart';

class AccountNoteAPIService {
  static final AccountNoteAPIService instance = AccountNoteAPIService._init();

  final String baseUrl = "http://192.168.1.23/notes_db/";

  AccountNoteAPIService._init();

  // Create - Thêm account mới
  Future<AccountNote> createAccount(AccountNote account) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts.php'),
      headers: {'Content-Type': 'application/json'},
      body: account.toJSON(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AccountNote.fromJSON(response.body);
    } else {
      throw Exception('Failed to create account: ${response.statusCode}');
    }
  }

  // Read - Đọc tất cả accounts
  Future<List<AccountNote>> getAllAccounts() async {
    final response = await http.get(Uri.parse('$baseUrl/accounts.php'));

    if (response.statusCode == 200) {
      List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => AccountNote.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load accounts: ${response.statusCode}');
    }
  }

  // Read - Đọc account theo id
  Future<AccountNote?> getAccountById(int id) async {
    final accounts = await getAllAccounts();
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Read - Đọc account theo userId
  Future<AccountNote?> getAccountByUserId(int userId) async {
    final accounts = await getAllAccounts();
    try {
      return accounts.firstWhere((account) => account.userId == userId);
    } catch (e) {
      return null;
    }
  }

  // Update - Cập nhật account
  Future<AccountNote> updateAccount(AccountNote account) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts.php?id=${account.id}&_method=PUT'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(account.toMap()),
    );

    if (response.statusCode == 200) {
      return AccountNote.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update account: ${response.statusCode}');
    }
  }

  // Delete - Xoá account
  Future<bool> deleteAccount(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts.php?id=$id&_method=DELETE'),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete account: ${response.statusCode}');
    }
  }

  // Đếm số lượng accounts
  Future<int> countAccounts() async {
    final accounts = await getAllAccounts();
    return accounts.length;
  }

  // Đăng nhập - Xác thực tài khoản
  Future<AccountNote?> login(String username, String password) async {
    final accounts = await getAllAccounts();
    try {
      final account = accounts.firstWhere(
            (account) =>
        account.username == username &&
            account.password == password &&
            account.status == 'active',
      );
      account.lastLogin = DateTime.now().toIso8601String();
      await updateAccount(account);
      return account;
    } catch (e) {
      return null;
    }
  }

  // Patch - Cập nhật một phần thông tin account
  Future<AccountNote> patchAccount(int id, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/accounts.php?id=$id&_method=PATCH'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return AccountNote.fromMap(jsonDecode(response.body));
    } else {
      throw Exception('Failed to patch account: ${response.statusCode}');
    }
  }

  // Đổi mật khẩu
  Future<AccountNote> changePassword(
      int id,
      String oldPassword,
      String newPassword,
      ) async {
    final account = await getAccountById(id);

    if (account == null) throw Exception('Account not found');
    if (account.password != oldPassword) throw Exception('Incorrect old password');

    return await patchAccount(id, {'password': newPassword});
  }

  // Reset mật khẩu
  Future<AccountNote> resetPassword(int id) async {
    final newPass = 'Reset${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}';
    return await patchAccount(id, {'password': newPass, 'status': 'active'});
  }

  // Lấy danh sách tài khoản theo trạng thái
  Future<List<AccountNote>> getAccountsByStatus(String status) async {
    final accounts = await getAllAccounts();
    return accounts.where((a) => a.status == status).toList();
  }

  // Kiểm tra tài khoản tồn tại
  Future<bool> isUsernameExists(String username) async {
    final accounts = await getAllAccounts();
    return accounts.any((a) => a.username == username);
  }
}