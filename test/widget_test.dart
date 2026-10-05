import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_app/app.dart';
import 'package:grocery_app/core/storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Kiểm tra khởi chạy GroceryApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
    await tester.pumpWidget(const GroceryApp());
    await tester.pump(const Duration(seconds: 3));
  });
}