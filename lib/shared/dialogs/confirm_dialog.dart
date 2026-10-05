import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class ConfirmDialog {
  /// Hộp thoại xác nhận thao tác (Đăng xuất, xóa địa chỉ, làm trống giỏ...)
  static void show({
    required String title,
    required String message,
    String confirmText = 'Đồng ý',
    String cancelText = 'Hủy',
    Color confirmColor = Colors.red,
    required VoidCallback onConfirm,
  }) {
    Get.defaultDialog(
      title: title,
      titleStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.black,
      ),
      titlePadding: const EdgeInsets.only(top: 20, left: 16, right: 16),
      contentPadding: const EdgeInsets.all(20),
      radius: 16,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: AppColors.grey,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                cancelText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Get.back();
                onConfirm();
              },
              child: Text(
                confirmText,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}