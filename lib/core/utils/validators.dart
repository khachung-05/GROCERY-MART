class Validators {
  // Kiểm tra họ và tên
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Họ và tên không được để trống';
    }
    if (value.trim().length < 2) {
      return 'Họ và tên quá ngắn';
    }
    return null;
  }

  // Kiểm tra định dạng email tiêu chuẩn bằng Regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  // Kiểm tra số điện thoại Việt Nam (bắt buộc đúng 10 chữ số)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại phải gồm 10 chữ số và bắt đầu bằng số 0';
    }
    return null;
  }

  // Kiểm tra mật khẩu (tối thiểu 6 ký tự)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có tối thiểu 6 ký tự';
    }
    return null;
  }

  // Kiểm tra mật khẩu xác nhận
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận lại mật khẩu';
    }
    if (value != originalPassword) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // Kiểm tra chuỗi rỗng thông thường
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }
}