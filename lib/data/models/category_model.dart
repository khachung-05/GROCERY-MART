class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String image;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.image,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        icon: json['icon'] ?? '',
        image: json['image'] ?? '',
        description: json['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'image': image,
        'description': description,
      };

  // Dùng cho SQLite DatabaseHelper
  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel.fromJson(map);

  Map<String, dynamic> toMap() => toJson();
}
