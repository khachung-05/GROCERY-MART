import 'package:intl/intl.dart';

class Formatters {
  // Định dạng tiền tệ VNĐ (ví dụ: 45.000 ₫)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  // Định dạng ngày giờ đặt hàng (ví dụ: 04/10/2026 22:19)
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (_) {
      return dateTimeString;
    }
  }

  // Định dạng ngày (ví dụ: 25/06/2026)
  static String formatDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return dateTimeString;
    }
  }
}