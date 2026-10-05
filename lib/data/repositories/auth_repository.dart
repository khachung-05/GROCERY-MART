import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/storage/local_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  /// Đăng nhập tài khoản
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userModel = UserModel.fromJson(data['data']);
        
        // Lưu phiên đăng nhập
        await LocalStorage.saveUserInfo(
          token: userModel.token ?? 'default_token',
          id: userModel.id,
          name: userModel.name,
          email: userModel.email,
          phone: userModel.phone,
          avatar: userModel.avatar,
        );
        return userModel;
      }
      return null;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      return null;
    }
  }

  /// Đăng ký tài khoản mới
  Future<({bool success, String message})> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return (
          success: true,
          message: data['message']?.toString() ?? 'Đăng ký thành công',
        );
      } else {
        return (
          success: false,
          message: data['message']?.toString() ?? data['error']?.toString() ?? 'Đăng ký thất bại',
        );
      }
    } catch (e) {
      print('Lỗi đăng ký: $e');
      return (success: false, message: 'Lỗi kết nối máy chủ: $e');
    }
  }

  /// Quên mật khẩu
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi quên mật khẩu: $e');
      return false;
    }
  }

  /// Đổi mật khẩu
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    final token = LocalStorage.token;
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi đổi mật khẩu: $e');
      return false;
    }
  }

  /// Cập nhật thông tin hồ sơ
  Future<bool> updateProfile(String name, String phone) async {
    final token = LocalStorage.token;
    if (token == null) return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name, 'phone': phone}),
      );

      if (response.statusCode == 200) {
        final userInfo = LocalStorage.getUserInfo();
        await LocalStorage.saveUserInfo(
          token: token,
          id: userInfo['id']!,
          name: name,
          email: userInfo['email']!,
          phone: phone,
          avatar: userInfo['avatar'],
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi cập nhật hồ sơ: $e');
      return false;
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    await LocalStorage.clearOnLogout();
  }
}