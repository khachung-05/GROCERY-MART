import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  // 12 Khóa lưu trữ theo đặc tả Bảng 3.8 trong báo cáo
  static const String _keyOnboardingSeen = 'onboarding_seen';
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserAvatar = 'user_avatar';
  static const String _keyCartItemsPrefix = 'cart_items';
  static const String _keyFavoriteIdsPrefix = 'favorite_ids';
  static const String _keyOrdersPrefix = 'orders';
  static const String _keyAddressesPrefix = 'addresses';
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keyRegisteredUsers = 'registered_users';
  static const String _keyThemeMode = 'theme_mode'; // 1: light, 2: dark
  static const String _keyReadNotificationIdsPrefix = 'read_notif_ids';
  static const String _keyDeletedNotificationIdsPrefix = 'deleted_notif_ids';
  static const String _keyStoreName = 'store_name';
  static const String _keyStoreHotline = 'store_hotline';
  static const String _keyStoreAddress = 'store_address';
  static const String _keyStoreShippingFee = 'store_shipping_fee';
  static const String _keyAutoAcceptOrders = 'store_auto_accept';
  static const String _keySoundNotification = 'store_sound_notification';

  /// Khởi tạo SharedPreferences lúc mở app (gọi tại main.dart)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== ONBOARDING ====================
  static bool get isOnboardingSeen =>
      _prefs.getBool(_keyOnboardingSeen) ?? false;

  static Future<bool> setOnboardingSeen(bool value) =>
      _prefs.setBool(_keyOnboardingSeen, value);

  // ==================== XÁC THỰC & NGƯỜI DÙNG ====================
  static bool get isLoggedIn => _prefs.getString(_keyAuthToken) != null;

  static String? get token => _prefs.getString(_keyAuthToken);

  static String? get currentUserId => _prefs.getString(_keyUserId);

  static Future<void> saveUserInfo({
    required String token,
    required String id,
    required String name,
    required String email,
    required String phone,
    String? avatar,
  }) async {
    await _prefs.setString(_keyAuthToken, token);
    await _prefs.setString(_keyUserId, id);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserPhone, phone);
    if (avatar != null) {
      await _prefs.setString(_keyUserAvatar, avatar);
    }
  }

  static Map<String, String?> getUserInfo() {
    return {
      'id': _prefs.getString(_keyUserId),
      'name': _prefs.getString(_keyUserName),
      'email': _prefs.getString(_keyUserEmail),
      'phone': _prefs.getString(_keyUserPhone),
      'avatar': _prefs.getString(_keyUserAvatar),
      'token': _prefs.getString(_keyAuthToken),
    };
  }

  // ==================== TÀI KHOẢN ĐĂNG KÝ CỤC BỘ ====================
  static List<String> getRegisteredUsers() {
    return _prefs.getStringList(_keyRegisteredUsers) ?? [];
  }

  static Future<bool> addRegisteredUser(String userJson) async {
    final list = getRegisteredUsers();
    list.add(userJson);
    return await _prefs.setStringList(_keyRegisteredUsers, list);
  }

  static Future<bool> updateRegisteredUser(String updatedUserJson, String email) async {
    final list = getRegisteredUsers();
    final index = list.indexWhere((item) {
      final map = jsonDecode(item) as Map<String, dynamic>;
      return map['email'] == email;
    });

    if (index != -1) {
      list[index] = updatedUserJson;
      return await _prefs.setStringList(_keyRegisteredUsers, list);
    }
    return false;
  }

  // ==================== HELPER KHÓA PHÂN TÁCH THEO USER ====================
  static String _getUserScopedKey(String prefix) {
    final uid = currentUserId ?? 'guest';
    return '${prefix}_$uid';
  }

  // ==================== GIỎ HÀNG (CART ITEMS) ====================
  static String? getCartItems() {
    return _prefs.getString(_getUserScopedKey(_keyCartItemsPrefix));
  }

  static Future<bool> saveCartItems(String cartJson) {
    return _prefs.setString(_getUserScopedKey(_keyCartItemsPrefix), cartJson);
  }

  static Future<bool> clearCartItems() {
    return _prefs.remove(_getUserScopedKey(_keyCartItemsPrefix));
  }

  // ==================== SẢN PHẨM YÊU THÍCH (FAVORITE IDS) ====================
  static List<String> getFavoriteIds() {
    return _prefs.getStringList(_getUserScopedKey(_keyFavoriteIdsPrefix)) ?? [];
  }

  static Future<bool> saveFavoriteIds(List<String> ids) {
    return _prefs.setStringList(_getUserScopedKey(_keyFavoriteIdsPrefix), ids);
  }

  // ==================== SỔ ĐỊA CHỈ (ADDRESSES) ====================
  static String? getAddresses() {
    return _prefs.getString(_getUserScopedKey(_keyAddressesPrefix));
  }

  static Future<bool> saveAddresses(String addressesJson) {
    return _prefs.setString(_getUserScopedKey(_keyAddressesPrefix), addressesJson);
  }

  // ==================== ĐƠN HÀNG (ORDERS) ====================
  static String? getOrders() {
    return _prefs.getString(_getUserScopedKey(_keyOrdersPrefix));
  }

  static Future<bool> saveOrders(String ordersJson) {
    return _prefs.setString(_getUserScopedKey(_keyOrdersPrefix), ordersJson);
  }

  // ==================== LỊCH SỬ TÌM KIẾM (RECENT SEARCHES) ====================
  static List<String> get recentSearches =>
      _prefs.getStringList(_keyRecentSearches) ?? [];

  static Future<bool> saveRecentSearches(List<String> searches) =>
      _prefs.setStringList(_keyRecentSearches, searches);

  static Future<bool> clearRecentSearches() =>
      _prefs.remove(_keyRecentSearches);

  // ==================== CẤU HÌNH THEME ====================
  static int get themeMode => _prefs.getInt(_keyThemeMode) ?? 1; // 1: light, 2: dark

  static Future<bool> saveThemeMode(int mode) =>
      _prefs.setInt(_keyThemeMode, mode);

  // ==================== THÔNG BÁO (NOTIFICATIONS) ====================
  static List<String> getReadNotificationIds() {
    return _prefs.getStringList(_getUserScopedKey(_keyReadNotificationIdsPrefix)) ?? [];
  }

  static Future<bool> saveReadNotificationIds(List<String> ids) {
    return _prefs.setStringList(_getUserScopedKey(_keyReadNotificationIdsPrefix), ids);
  }

  static List<String> getDeletedNotificationIds() {
    return _prefs.getStringList(_getUserScopedKey(_keyDeletedNotificationIdsPrefix)) ?? [];
  }

  static Future<bool> saveDeletedNotificationIds(List<String> ids) {
    return _prefs.setStringList(_getUserScopedKey(_keyDeletedNotificationIdsPrefix), ids);
  }

  // ==================== CẤU HÌNH GIAN HÀNG & HỆ THỐNG ====================
  static String get storeName => _prefs.getString(_keyStoreName) ?? 'Grocery Fresh Mart';
  static Future<bool> setStoreName(String val) => _prefs.setString(_keyStoreName, val);

  static String get storeHotline => _prefs.getString(_keyStoreHotline) ?? '1900 6789 - 0912345678';
  static Future<bool> setStoreHotline(String val) => _prefs.setString(_keyStoreHotline, val);

  static String get storeAddress => _prefs.getString(_keyStoreAddress) ?? 'Vĩnh Tuy 2, Mạo Khê, Uông Bí, Quảng Ninh';
  static Future<bool> setStoreAddress(String val) => _prefs.setString(_keyStoreAddress, val);

  static double get storeShippingFee => _prefs.getDouble(_keyStoreShippingFee) ?? 15000.0;
  static Future<bool> setStoreShippingFee(double val) => _prefs.setDouble(_keyStoreShippingFee, val);

  static bool get autoAcceptOrders => _prefs.getBool(_keyAutoAcceptOrders) ?? true;
  static Future<bool> setAutoAcceptOrders(bool val) => _prefs.setBool(_keyAutoAcceptOrders, val);

  static bool get soundNotification => _prefs.getBool(_keySoundNotification) ?? true;
  static Future<bool> setSoundNotification(bool val) => _prefs.setBool(_keySoundNotification, val);

  // ==================== ĐĂNG XUẤT ====================
  static Future<void> clearOnLogout() async {
    await _prefs.remove(_keyAuthToken);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserPhone);
    await _prefs.remove(_keyUserAvatar);
  }

  // Hàm đọc/ghi chuỗi nguyên bản
  static String? getString(String key) => _prefs.getString(key);
  static Future<bool> setString(String key, String value) => _prefs.setString(key, value);
}