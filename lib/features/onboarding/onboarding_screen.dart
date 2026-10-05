import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Dữ liệu 3 trang Onboarding mô tả tại mục 3.5.4 của báo cáo
  final List<Map<String, dynamic>> _pages = [
    {
      'icon': '🍎',
      'bgColor': const Color(0xFFE8F5E9), // Xanh lá nhạt
      'title': 'Thực phẩm tươi sạch',
      'desc':
      'Lựa chọn từ hàng ngàn sản phẩm tươi sạch, đảm bảo chất lượng mỗi ngày cho gia đình bạn.',
    },
    {
      'icon': '🚚',
      'bgColor': const Color(0xFFE3F2FD), // Xanh dương nhạt
      'title': 'Giao hàng nhanh chóng',
      'desc':
      'Đặt hàng giao tận nhà trong vòng 2 tiếng, giữ trọn độ tươi ngon của từng loại thực phẩm.',
    },
    {
      'icon': '💵',
      'bgColor': const Color(0xFFFFF3E0), // Cam nhạt
      'title': 'Thanh toán khi nhận hàng',
      'desc':
      'Đảm bảo an tâm tuyệt đối với phương thức nhận hàng kiểm tra rồi mới thanh toán (COD).',
    },
  ];

  /// Hoàn tất Onboarding và lưu bền vững vào SharedPreferences
  Future<void> _finishOnboarding() async {
    await LocalStorage.setOnboardingSeen(true);
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Nút "Bỏ qua" ở góc trên bên phải
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text(
                    'Bỏ qua',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Khu vực PageView 3 slide
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Vòng tròn màu nền chứa emoji lớn (Hình 3.5)
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: page['bgColor'] as Color,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            page['icon'] as String,
                            style: const TextStyle(fontSize: 90),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Tiêu đề lớn
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mô tả chi tiết
                        Text(
                          page['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bộ chỉ báo trang (Indicator) và Nút điều hướng chân trang
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: Color(0xFFE0E0E0),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                      spacing: 6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nút "Tiếp theo" hoặc "Bắt đầu"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _finishOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Bắt đầu ngay' : 'Tiếp theo',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}