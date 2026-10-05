import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/app_routes.dart';
import 'core/routes/app_pages.dart';
import 'core/storage/local_storage.dart';
import 'core/themes/app_theme.dart';

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  ThemeMode _getInitialThemeMode() {
    // 2: Dark mode, 1: Light mode theo Bảng 3.8 trong báo cáo
    return LocalStorage.themeMode == 2 ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Grocery App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _getInitialThemeMode(),
      locale: const Locale('vi', 'VN'),
      fallbackLocale: const Locale('vi', 'VN'),
      defaultTransition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}