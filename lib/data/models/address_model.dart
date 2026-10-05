class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String city;
  final String district;
  final String ward;
  final String detailAddress;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.city,
    required this.district,
    required this.ward,
    required this.detailAddress,
    this.isDefault = false,
  });

  /// Thuộc tính tính toán ghép thành chuỗi địa chỉ hoàn chỉnh
  String get fullAddress => '$detailAddress, $ward, $district, $city';

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json['id'] ?? '',
    fullName: json['fullName'] ?? '',
    phone: json['phone'] ?? '',
    city: json['city'] ?? '',
    district: json['district'] ?? '',
    ward: json['ward'] ?? '',
    detailAddress: json['detailAddress'] ?? '',
    isDefault: json['isDefault'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'city': city,
    'district': district,
    'ward': ward,
    'detailAddress': detailAddress,
    'isDefault': isDefault,
  };

  AddressModel copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? city,
    String? district,
    String? ward,
    String? detailAddress,
    bool? isDefault,
  }) =>
      AddressModel(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        phone: phone ?? this.phone,
        city: city ?? this.city,
        district: district ?? this.district,
        ward: ward ?? this.ward,
        detailAddress: detailAddress ?? this.detailAddress,
        isDefault: isDefault ?? this.isDefault,
      );
}