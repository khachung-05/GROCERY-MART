import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../auth/auth_controller.dart';
import '../home/main_controller.dart';
import 'address_book_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isDarkMode;
  Map<String, String?> _userInfo = {};

  @override
  void initState() {
    super.initState();
    _isDarkMode = LocalStorage.themeMode == 2;
    _loadUserInfo();
  }

  void _loadUserInfo() {
    setState(() {
      _userInfo = LocalStorage.getUserInfo();
    });
  }

  void _toggleDarkMode(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final modeInt = value ? 2 : 1;
    await LocalStorage.saveThemeMode(modeInt);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  void _showLogoutDialog() {
    Get.defaultDialog(
      title: 'Đăng xuất',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleText: 'Bạn có chắc chắn muốn đăng xuất không?',
      textConfirm: 'Đăng xuất',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: AppColors.black,
      onConfirm: () async {
        Get.back();
        final authController = Get.isRegistered<AuthController>()
            ? Get.find<AuthController>()
            : Get.put(AuthController());
        await authController.logout();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = LocalStorage.isLoggedIn;
    final userName = _userInfo['name'] ?? 'Khách hàng';
    final userEmail = _userInfo['email'] ?? 'Chưa đăng nhập';
    final userPhone = _userInfo['phone'] ?? '---';

    final isAdmin = isLoggedIn && (userEmail.toLowerCase() == 'admin@gmail.com' || userName.contains('Quản Trị Viên'));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header Gradient xanh lá
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, bottom: 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFF1976D2),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userPhone,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Nội dung Menu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nhóm Admin Quản trị (hiển thị khi đăng nhập tài khoản Quản trị viên)
                  if (isAdmin) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.shield_outlined, color: AppColors.primaryLight, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ADMIN CONSOLE',
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  Text(
                                    'Trung Tâm Quản Trị Hệ Thống',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xFF334155)),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.dashboard_customize_outlined, color: Colors.white, size: 20),
                            ),
                            title: const Text(
                              'Bảng Quản Trị Console (Admin Dashboard)',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Quản lý kho hàng, cập nhật giá & duyệt đơn',
                              style: TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primaryLight, size: 14),
                            onTap: () => Get.toNamed(AppRoutes.adminDashboard),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nhóm 1: Tài khoản
                  _buildSectionTitle(Icons.person_outline, 'Tài khoản'),
                  _buildMenuContainer([
                    _buildMenuItem(
                      icon: Icons.edit_outlined,
                      iconColor: AppColors.primary,
                      title: 'Thông tin cá nhân',
                      onTap: () {
                        if (!isLoggedIn) {
                          Get.toNamed(AppRoutes.login);
                        } else {
                          Get.toNamed(AppRoutes.editProfile)?.then((_) => _loadUserInfo());
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      iconColor: AppColors.primary,
                      title: 'Đổi mật khẩu',
                      onTap: () {
                        if (!isLoggedIn) {
                          Get.toNamed(AppRoutes.login);
                        } else {
                          Get.toNamed(AppRoutes.changePassword);
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.primary,
                      title: 'Địa chỉ của tôi',
                      onTap: () {
                        if (!isLoggedIn) {
                          Get.toNamed(AppRoutes.login);
                        } else {
                          // Điều hướng trực tiếp đến màn hình Sổ địa chỉ
                          Get.to(() => const AddressBookScreen());
                        }
                      },
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Nhóm 2: Mua sắm
                  _buildSectionTitle(Icons.shopping_bag_outlined, 'Mua sắm'),
                  _buildMenuContainer([
                    _buildMenuItem(
                      icon: Icons.assignment_outlined,
                      iconColor: AppColors.primary,
                      title: 'Đơn hàng của tôi',
                      onTap: () {
                        if (Get.isRegistered<MainController>()) {
                          Get.find<MainController>().changeTab(3);
                        } else {
                          Get.toNamed(AppRoutes.orders);
                        }
                      },
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildMenuItem(
                      icon: Icons.favorite_border,
                      iconColor: AppColors.primary,
                      title: 'Sản phẩm yêu thích',
                      onTap: () => Get.toNamed(AppRoutes.favorites),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Nhóm 3: Cài đặt
                  _buildSectionTitle(Icons.settings_outlined, 'Cài đặt'),
                  _buildMenuContainer([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Chế độ tối',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          Switch(
                            value: _isDarkMode,
                            activeThumbColor: AppColors.primary,
                            onChanged: _toggleDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Nút Đăng xuất / Đăng nhập
                  if (isLoggedIn)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Get.toNamed(AppRoutes.login),
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Đăng nhập ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: AppColors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}