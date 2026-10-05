import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressItem {
  final String id;
  final String name;
  final String phone;
  final String address;
  final bool isDefault;

  AddressItem({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.isDefault = false,
  });

  AddressItem copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    bool? isDefault,
  }) {
    return AddressItem(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'isDefault': isDefault,
  };

  factory AddressItem.fromMap(Map<String, dynamic> map) => AddressItem(
    id: map['id']?.toString() ?? '',
    name: map['name']?.toString() ?? '',
    phone: map['phone']?.toString() ?? '',
    address: (map['address'] ?? map['fullAddress'])?.toString() ?? '',
    isDefault: map['isDefault'] == true || map['isDefault'] == 1,
  );
}

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  static const String _storageKey = 'user_saved_addresses';
  List<AddressItem> addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddressesFromStorage();
  }

  // 1. Đọc dữ liệu từ bộ nhớ máy qua SharedPreferences
  Future<void> _loadAddressesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_storageKey);

      if (rawJson != null && rawJson.isNotEmpty) {
        final List decoded = jsonDecode(rawJson);
        if (decoded.isNotEmpty) {
          setState(() {
            addresses = decoded.map((e) {
              final item = AddressItem.fromMap(e);
              if (item.name == 'Nguyễn Anh Quân') {
                return item.copyWith(name: 'Phạm Khắc Hùng');
              }
              return item;
            }).toList();
          });
          _saveToStorage();
          return;
        }
      }
    } catch (e) {
      debugPrint('Lỗi đọc địa chỉ từ SharedPreferences: $e');
    }

    // Nếu bộ nhớ máy hoàn toàn trống, nạp 2 địa chỉ ban đầu như báo cáo
    setState(() {
      addresses = [
        AddressItem(
          id: '1',
          name: 'Nguyễn Văn An',
          phone: '0912345678',
          address: '123 Nguyễn Văn Linh, Phường Tân Phú, Quận 7, TP. Hồ Chí Minh',
          isDefault: false,
        ),
        AddressItem(
          id: '2',
          name: 'Phạm Khắc Hùng',
          phone: '0123456789',
          address: 'Vĩnh Tuy 2, Mạo Khê, Uông Bí, Quảng Ninh',
          isDefault: true,
        ),
      ];
    });
    _saveToStorage();
  }

  // 2. Lưu trực tiếp vào SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final listMap = addresses.map((e) => e.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(listMap));
    } catch (e) {
      debugPrint('Lỗi lưu địa chỉ vào SharedPreferences: $e');
    }
  }

  void _setDefault(String id) {
    setState(() {
      addresses = addresses.map((item) {
        return item.copyWith(isDefault: item.id == id);
      }).toList();
    });
    _saveToStorage();
  }

  void _deleteAddress(String id) {
    setState(() {
      addresses.removeWhere((item) => item.id == id);
    });
    _saveToStorage();
  }

  void _showAddEditDialog([AddressItem? item]) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final phoneCtrl = TextEditingController(text: item?.phone ?? '');
    final addressCtrl = TextEditingController(text: item?.address ?? '');

    Get.defaultDialog(
      title: item == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Họ và tên'),
            ),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Số điện thoại'),
            ),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(labelText: 'Địa chỉ cụ thể'),
            ),
          ],
        ),
      ),
      textConfirm: 'Lưu',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF2E7D32),
      onConfirm: () {
        if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty || addressCtrl.text.isEmpty) {
          Get.snackbar('Lỗi', 'Vui lòng nhập đầy đủ thông tin');
          return;
        }

        setState(() {
          if (item == null) {
            addresses.add(AddressItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: nameCtrl.text.trim(),
              phone: phoneCtrl.text.trim(),
              address: addressCtrl.text.trim(),
              isDefault: addresses.isEmpty,
            ));
          } else {
            final index = addresses.indexWhere((e) => e.id == item.id);
            if (index != -1) {
              addresses[index] = item.copyWith(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addressCtrl.text.trim(),
              );
            }
          }
        });
        _saveToStorage();
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Sổ địa chỉ',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final item = addresses[index];
          final isDefault = item.isDefault;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _setDefault(item.id);
              Get.back(result: item);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDefault ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
                  width: isDefault ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 12),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDefault ? const Color(0xFF2E7D32) : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isDefault
                          ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            if (isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Mặc định',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.phone,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.address,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isDefault)
                              InkWell(
                                onTap: () => _setDefault(item.id),
                                child: const Text(
                                  'Đặt làm mặc định',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              const SizedBox(),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _showAddEditDialog(item),
                                  child: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2E7D32)),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () => _deleteAddress(item.id),
                                  child: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE53935)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _showAddEditDialog(),
              child: const Text(
                '+ Thêm địa chỉ mới',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}