class AppConstants {
  // Thông tin ứng dụng
  static const String appName = 'Grocery App';
  static const String appVersion = '1.0.0';

  // Thời gian chờ và hiệu ứng (Splash, Transition, Network Mock)
  static const int splashDelaySeconds = 2;
  static const int transitionDurationMs = 250;
  static const int mockNetworkDelayMs = 800;

  // Cấu hình tiền tệ & chi phí mặc định
  static const String currencySymbol = '₫';
  static const double defaultShippingFee = 15000.0;
  static const double expressShippingFee = 35000.0;

  // Cấu hình giao diện & Padding chuẩn
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // Giới hạn dữ liệu nhập (Validation rules)
  static const int minPasswordLength = 6;
  static const int phoneLength = 10;

  // Phương thức thanh toán hỗ trợ
  static const String paymentCOD = 'COD';
  static const String paymentMoMo = 'MoMo';
  static const String paymentVNPay = 'VNPAY';

  // Trạng thái đơn hàng
  static const String orderStatusPending = 'Chờ xử lý';
  static const String orderStatusShipping = 'Đang giao hàng';
  static const String orderStatusCompleted = 'Đã hoàn thành';
  static const String orderStatusCancelled = 'Đã hủy';
}