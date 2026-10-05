import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_notification.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  // Controllers cho Form Đăng nhập
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Controllers cho Form Đăng ký
  final regNameController = TextEditingController();
  final regEmailController = TextEditingController();
  final regPhoneController = TextEditingController();
  final regPasswordController = TextEditingController();
  final regConfirmPasswordController = TextEditingController();

  // Trạng thái Reactive
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    if (LocalStorage.isLoggedIn) {final info = LocalStorage.getUserInfo();
      currentUser.value = UserModel(
        id: info['id'] ?? '',
        name: info['name'] ?? '',
        email: info['email'] ?? '',
        phone: info['phone'] ?? '',
        avatar: info['avatar'] ?? '',
        token: info['token'] ?? '',
      );
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  /// Nghiệp vụ Đăng nhập
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppNotification.showError(
        title: 'Chưa nhập thông tin',
        message: 'Vui lòng điền đầy đủ Email và Mật khẩu',
      );
      return;
    }

    isLoading.value = true;
    final user = await _authRepo.login(email, password);
    isLoading.value = false;

    if (user != null) {
      currentUser.value = user;
      AppNotification.showLoginSuccess(user);
      if (user.email.toLowerCase() == 'admin@gmail.com') {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.main);
      }
    } else {
      AppNotification.showError(
        title: 'Đăng nhập không thành công',
        message: 'Email hoặc mật khẩu không chính xác',
      );
    }
  }

  /// Nghiệp vụ Đăng ký tài khoản mới
  Future<void> register() async {
    final name = regNameController.text.trim();
    final email = regEmailController.text.trim();
    final phone = regPhoneController.text.trim();
    final password = regPasswordController.text;
    final confirmPassword = regConfirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      AppNotification.showError(
        title: 'Thông tin chưa đầy đủ',
        message: 'Vui lòng nhập đầy đủ các trường thông tin',
      );
      return;
    }

    if (password != confirmPassword) {
      AppNotification.showError(
        title: 'Mật khẩu không khớp',
        message: 'Mật khẩu xác nhận không trùng khớp với mật khẩu',
      );
      return;
    }

    isLoading.value = true;
    final result = await _authRepo.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
    isLoading.value = false;

    if (result.success) {
      AppNotification.showSuccess(
        title: 'Đăng ký thành công',
        message: result.message,
      );
      Get.offNamed(AppRoutes.login);
    } else {
      AppNotification.showError(
        title: 'Đăng ký không thành công',
        message: result.message,
      );
    }
  }

  /// Bỏ qua đăng nhập và truy cập với vai trò Guest
  void skipLogin() {
    Get.offAllNamed(AppRoutes.main);
  }

  /// Đăng xuất
  Future<void> logout() async {
    await _authRepo.logout();
    currentUser.value = null;
    emailController.clear();
    passwordController.clear();
    regNameController.clear();
    regEmailController.clear();
    regPhoneController.clear();
    regPasswordController.clear();
    regConfirmPasswordController.clear();
    Get.offAllNamed(AppRoutes.login);
  }
}