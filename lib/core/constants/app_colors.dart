import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32); // Xanh lá cây thực phẩm tươi
  static const Color primaryLight = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color background = Color(0xFFF8F9FA);
  static const Color white = Colors.white;
  static const Color black = Color(0xFF212121);
  static const Color grey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color red = Color(0xFFE53935);
  static const Color orange = Color(0xFFFF9800);
  
  // Tông màu bổ trợ đồng nhất theo màu primary
  static Color get primarySurface => primary.withValues(alpha: 0.08);
  static Color get primaryBorder => primary.withValues(alpha: 0.25);
}