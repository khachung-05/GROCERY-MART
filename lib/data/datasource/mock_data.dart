import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/voucher_model.dart';

class MockData {
  // 1. Danh sách 2 tài khoản mẫu (demo)
  static List<Map<String, String>> mockUsers = [
    {
      'id': 'user_001',
      'name': 'Phạm Khắc Hùng',
      'email': 'user@gmail.com',
      'phone': '0912345678',
      'password': 'password123',
      'token': 'mock_token_user_001',
      'avatar':
          'https://ui-avatars.com/api/?name=Pham+Khac+Hung&background=2E7D32&color=fff',
    },
    {
      'id': 'user_002',
      'name': 'Quản Trị Viên',
      'email': 'admin@gmail.com',
      'phone': '0987654321',
      'password': 'adminpassword',
      'token': 'mock_token_admin_002',
      'avatar':
          'https://ui-avatars.com/api/?name=Admin&background=1B5E20&color=fff',
    }
  ];

  // 2. Danh sách 8 danh mục thực phẩm mẫu
  static List<CategoryModel> categories = [
    CategoryModel(
      id: 'fruit',
      name: 'Trái cây',
      icon: '🍎',
      image:
          'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500&q=80',
      description: 'Trái cây tươi ngon, giàu vitamin và khoáng chất tự nhiên',
    ),
    CategoryModel(
      id: 'veg',
      name: 'Rau củ',
      icon: '🥦',
      image:
          'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=500&q=80',
      description: 'Rau xanh, củ quả tươi sạch hữu cơ an toàn cho sức khỏe',
    ),
    CategoryModel(
      id: 'meat',
      name: 'Thịt',
      icon: '🥩',
      image:
          'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=500&q=80',
      description: 'Thịt heo, bò, gà tươi sống được kiểm dịch an toàn',
    ),
    CategoryModel(
      id: 'seafood',
      name: 'Hải sản',
      icon: '🦐',
      image:
          'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=500&q=80',
      description: 'Tôm, cua, cá, mực tươi đánh bắt trong ngày',
    ),
    CategoryModel(
      id: 'drink',
      name: 'Đồ uống',
      icon: '🥤',
      image:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500&q=80',
      description: 'Nước trái cây ép nguyên chất, sữa hạt và đồ uống giải khát',
    ),
    CategoryModel(
      id: 'snack',
      name: 'Đồ ăn vặt',
      icon: '🍿',
      image:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=500&q=80',
      description: 'Các loại hạt dinh dưỡng, bánh snack và trái cây sấy',
    ),
    CategoryModel(
      id: 'dairy',
      name: 'Sữa & Trứng',
      icon: '🥛',
      image:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=500&q=80',
      description: 'Sữa tươi tiệt trùng, bơ, phô mai và trứng gà sạch',
    ),
    CategoryModel(
      id: 'bakery',
      name: 'Bánh mì',
      icon: '🍞',
      image:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=500&q=80',
      description: 'Bánh mì sandwich nguyên cám tươi mới nướng mỗi ngày',
    ),
  ];

  // 3. Danh sách các sản phẩm thực phẩm chi tiết
  static List<ProductModel> products = [
    ProductModel(
      id: 'prod_001',
      name: 'Táo Fuji Nhật',
      description:
          'Táo Fuji Nhật Bản chính gốc, ngọt giòn, mọng nước. Giàu vitamin C và chất xơ. Bảo quản nơi khô ráo, thoáng mát hoặc trong tủ lạnh.',
      price: 45000,
      originalPrice: 60000,
      image:
          'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&q=80',
      categoryId: 'fruit',
      unit: '1kg',
      rating: 4.8,
      stock: 50,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_002',
      name: 'Nho Đen Úc',
      description:
          'Nho đen không hạt Úc quả to, mọng nước, vỏ mỏng vị ngọt đậm đà thơm ngát.',
      price: 85000,
      originalPrice: 105000,
      image:
          'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&q=80',
      categoryId: 'fruit',
      unit: '500g',
      rating: 4.9,
      stock: 30,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_003',
      name: 'Dâu Tây Đà Lạt',
      description:
          'Dâu tây Đà Lạt chín cây tự nhiên, vị ngọt thanh xen chút chua nhẹ mát lành.',
      price: 65000,
      originalPrice: 80000,
      image:
          'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=600&q=80',
      categoryId: 'fruit',
      unit: '250g',
      rating: 4.7,
      stock: 25,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_004',
      name: 'Xoài Cát Hòa Lộc',
      description:
          'Xoài cát Hòa Lộc Tiền Giang chuẩn VietGAP, mùi thơm nồng nàn vị ngọt lịm không xơ.',
      price: 55000,
      originalPrice: 70000,
      image:
          'https://images.unsplash.com/photo-1553279768-865429fa0078?w=600&q=80',
      categoryId: 'fruit',
      unit: '1kg',
      rating: 4.6,
      stock: 40,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_005',
      name: 'Cam Sành Mọng Nước',
      description:
          'Cam sành Hàm Yên vỏ mỏng nhiều nước, bổ sung lượng lớn vitamin C tăng sức đề kháng.',
      price: 35000,
      originalPrice: 42000,
      image:
          'https://images.unsplash.com/photo-1547514701-42782101795e?w=600&q=80',
      categoryId: 'fruit',
      unit: '1kg',
      rating: 4.5,
      stock: 60,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_006',
      name: 'Dứa Mật Tươi Ngon',
      description:
          'Dứa mật quả to vàng ươm, ngọt đậm nhiều nước, thích hợp ăn trực tiếp hoặc ép nước.',
      price: 25000,
      originalPrice: 30000,
      image:
          'https://images.unsplash.com/photo-1550258987-190a2d41a8ba?w=600&q=80',
      categoryId: 'fruit',
      unit: '1 quả',
      rating: 4.6,
      stock: 35,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_007',
      name: 'Súp Lơ Xanh Hữu Cơ',
      description:
          'Bông cải xanh Đà Lạt giòn ngọt, giàu khoáng chất và chất xơ có lợi cho tiêu hóa.',
      price: 32000,
      originalPrice: 40000,
      image:
          'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=600&q=80',
      categoryId: 'veg',
      unit: '500g',
      rating: 4.8,
      stock: 45,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_008',
      name: 'Cà Rốt Đà Lạt Tươi',
      description:
          'Cà rốt tươi ngon vỏ mỏng, giàu beta-carotene tốt cho mắt và sức khỏe gia đình.',
      price: 20000,
      image:
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=600&q=80',
      categoryId: 'veg',
      unit: '1kg',
      rating: 4.7,
      stock: 55,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_009',
      name: 'Cà Chua Bi Hữu Cơ',
      description:
          'Cà chua bi ngọt thanh, mọng nước, phù hợp làm món salad hoặc ăn nhẹ dinh dưỡng.',
      price: 28000,
      image:
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&q=80',
      categoryId: 'veg',
      unit: '500g',
      rating: 4.6,
      stock: 40,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_010',
      name: 'Thịt Bò Mỹ Cắt Lát',
      description:
          'Ba chỉ bò Mỹ vân mỡ đều, mềm mọng ngọt thịt, chuyên dùng cho các món lẩu và nướng.',
      price: 110000,
      originalPrice: 135000,
      image:
          'https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=600&q=80',
      categoryId: 'meat',
      unit: '500g',
      rating: 4.9,
      stock: 20,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_011',
      name: 'Tôm Sú Tươi Sống',
      description:
          'Tôm sú loại 1 vỏ bóng chắc thịt, tươi sống giữ trọn hương vị biển cả.',
      price: 145000,
      originalPrice: 170000,
      image:
          'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=600&q=80',
      categoryId: 'seafood',
      unit: '500g',
      rating: 4.9,
      stock: 15,
      isFavorite: false,
    ),
    ProductModel(
      id: 'prod_012',
      name: 'Sữa Tươi Tiệt Trùng Vinamilk',
      description:
          'Sữa tươi 100% tiệt trùng không đường bổ sung canxi và dưỡng chất thiết yếu hàng ngày.',
      price: 32000,
      image:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600&q=80',
      categoryId: 'dairy',
      unit: '1 lít',
      rating: 4.8,
      stock: 60,
      isFavorite: false,
    ),
  ];

  // 4. Danh sách đơn hàng mẫu (demo)
  static List<OrderModel> orders = [
    OrderModel(
      id: 'ORD-8821',
      userId: 'user_001',
      items: [
        OrderItemModel(
          productId: 'prod_001',
          productName: 'Táo Envy New Zealand',
          productImage:
              'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&q=80',
          price: 85000,
          quantity: 2,
          unit: '1 kg',
        ),
        OrderItemModel(
          productId: 'prod_004',
          productName: 'Cam Sành Tiền Giang',
          productImage:
              'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?w=600&q=80',
          price: 35000,
          quantity: 3,
          unit: '1 kg',
        ),
      ],
      subtotal: 275000,
      shippingFee: 20000,
      totalAmount: 295000,
      shippingAddress: '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
      receiverName: 'Phạm Khắc Hùng',
      receiverPhone: '0912345678',
      paymentMethod: 'Tiền mặt (COD)',
      status: 'Đã giao',
      orderDate: '2026-09-14 08:00:00',
    ),
    OrderModel(
      id: 'ORD-7612',
      userId: 'user_001',
      items: [
        OrderItemModel(
          productId: 'prod_007',
          productName: 'Thịt Ba Chỉ Heo Quế',
          productImage:
              'https://images.unsplash.com/photo-1602498456745-e9503b30470b?w=600&q=80',
          price: 130000,
          quantity: 1,
          unit: '1 kg',
        ),
        OrderItemModel(
          productId: 'prod_005',
          productName: 'Cà Chua Beef Hữu Cơ',
          productImage:
              'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=600&q=80',
          price: 40000,
          quantity: 1,
          unit: '500g',
        ),
      ],
      subtotal: 170000,
      shippingFee: 15000,
      totalAmount: 185000,
      shippingAddress: '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
      receiverName: 'Phạm Khắc Hùng',
      receiverPhone: '0912345678',
      paymentMethod: 'Chuyển khoản / Ví MoMo',
      status: 'Đã giao',
      orderDate: '2026-09-12 14:30:00',
    ),
    OrderModel(
      id: 'ORD-6503',
      userId: 'user_001',
      items: [
        OrderItemModel(
          productId: 'prod_011',
          productName: 'Tôm Sú Tươi Sống Cà Mau',
          productImage:
              'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=600&q=80',
          price: 145000,
          quantity: 1,
          unit: '500g',
        ),
      ],
      subtotal: 145000,
      shippingFee: 20000,
      totalAmount: 165000,
      shippingAddress: '123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
      receiverName: 'Phạm Khắc Hùng',
      receiverPhone: '0912345678',
      paymentMethod: 'Tiền mặt (COD)',
      status: 'Chờ xử lý',
      orderDate: '2026-09-14 07:15:00',
    ),
  ];

  // 5. Danh sách mã giảm giá mẫu (Vouchers)
  static List<VoucherModel> mockVouchers = [
    VoucherModel(
      id: 'VOUCHER-01',
      code: 'GIAM10K',
      title: 'Giảm 10.000đ cho đơn từ 50k',
      discountType: 'FIXED',
      discountValue: 10000,
      minOrderValue: 50000,
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      description: 'Áp dụng cho mọi đơn hàng thực phẩm sạch từ 50.000đ',
    ),
    VoucherModel(
      id: 'VOUCHER-02',
      code: 'FRESH20',
      title: 'Giảm 20.000đ cho đơn từ 100k',
      discountType: 'FIXED',
      discountValue: 20000,
      minOrderValue: 100000,
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      description: 'Ưu đãi dành cho đơn hàng nông sản từ 100.000đ',
    ),
    VoucherModel(
      id: 'VOUCHER-03',
      code: 'HOANXU10',
      title: 'Giảm 10% tối đa 50.000đ',
      discountType: 'PERCENT',
      discountValue: 10,
      minOrderValue: 150000,
      maxDiscount: 50000,
      expiryDate: DateTime.now().add(const Duration(days: 20)),
      description: 'Giảm 10% cho toàn bộ giỏ hàng rau củ quả từ 150.000đ',
    ),
    VoucherModel(
      id: 'VOUCHER-04',
      code: 'FREESHIP',
      title: 'Miễn phí giao hàng (Giảm 15k ship)',
      discountType: 'SHIPPING',
      discountValue: 15000,
      minOrderValue: 120000,
      expiryDate: DateTime.now().add(const Duration(days: 60)),
      description: 'Miễn phí vận chuyển tiêu chuẩn cho đơn từ 120.000đ',
    ),
    VoucherModel(
      id: 'VOUCHER-05',
      code: 'GROCERY5K',
      title: 'Giảm 5.000đ cho mọi đơn hàng',
      discountType: 'FIXED',
      discountValue: 5000,
      minOrderValue: 0,
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      description: 'Không giới hạn giá trị đơn hàng tối thiểu',
    ),
  ];
}
