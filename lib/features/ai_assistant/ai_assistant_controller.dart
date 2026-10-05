import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../cart/cart_controller.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<ProductModel>? suggestedProducts;
  final List<String>? quickReplies;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedProducts,
    this.quickReplies,
  });
}

class AiAssistantController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final CartController _cartController = Get.find<CartController>();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final RxBool isTyping = false.obs;
  final textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<String> quickPromptSuggestions = [
    '💡 Hôm nay ăn gì?',
    '🥗 Gợi ý món chay / rau sạch',
    '🍎 Trái cây tươi ngon',
    '🥩 Thực phẩm giàu Protein',
    '🔥 Sản phẩm nổi bật giảm giá',
  ];

  @override
  void onInit() {
    super.onInit();
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    messages.add(
      ChatMessageModel(
        id: const Uuid().v4(),
        text:
            'Xin chào! Tôi là Trợ lý AI Đi Chợ 🍏🤖\n\nTôi có thể giúp bạn gợi ý thực đơn món ăn hôm nay, tư vấn giá cả thực phẩm tươi sạch và gợi ý các mặt hàng phù hợp với nhu cầu của bạn!',
        isUser: false,
        timestamp: DateTime.now(),
        quickReplies: [
          'Hôm nay ăn gì?',
          'Tư vấn rau củ quả tươi',
          'Sản phẩm nhiều dinh dưỡng',
        ],
      ),
    );
  }

  Future<void> sendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    textController.clear();

    // 1. Thêm tin nhắn của User
    messages.add(
      ChatMessageModel(
        id: const Uuid().v4(),
        text: query,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );
    _scrollToBottom();

    // 2. Giả lập AI suy nghĩ
    isTyping.value = true;
    await Future.delayed(const Duration(milliseconds: 900));

    // 3. Phân tích câu hỏi và sinh phản hồi thông minh từ danh mục cửa hàng
    // 3. Phân tích câu hỏi và sinh phản hồi thông minh từ danh mục cửa hàng
    final response = await _generateAiResponse(query);

    isTyping.value = false;
    messages.add(response);
    _scrollToBottom();
  }

  Future<ChatMessageModel> _generateAiResponse(String input) async {
    final lower = input.toLowerCase();
    final allProducts = await _productRepo.getProducts();

    List<ProductModel> matchedProducts = [];
    String replyText = '';

    if (lower.contains('hôm nay ăn gì') ||
        lower.contains('món ăn') ||
        lower.contains('thực đơn') ||
        lower.contains('gợi ý món')) {
      replyText = '✨ **Gợi ý thực đơn hấp dẫn hôm nay:**\n\n'
          '🍲 **Món 1: Canh Rau Củ Hầm Sườn/Thịt Bò**\n'
          'Tốt cho sức khỏe, vị ngọt thanh mát tự nhiên từ rau củ tươi.\n\n'
          '🍳 **Món 2: Thịt Bò Xào Cần Tây / Rau Cải**\n'
          'Đậm đà hương vị, giàu sắt và chất xơ.\n\n'
          '🍊 **Tráng miệng:** Trái cây tươi giàu Vitamin C!\n\n'
          'Dưới đây là một số nguyên liệu tươi ngon sẵn có tại cửa hàng:';

      matchedProducts = allProducts.take(3).toList();
    } else if (lower.contains('rau') ||
        lower.contains('chay') ||
        lower.contains('củ')) {
      replyText = '🥦 **Rau củ quả sạch hữu cơ tốt cho sức khỏe:**\n\n'
          'Rau xanh chứa nhiều chất xơ, vitamin A, C giúp tăng cường đề kháng và đẹp da. Dưới đây là các loại rau củ tươi vừa về hôm nay:';
      matchedProducts = allProducts
          .where((p) =>
              p.categoryId == 'veg' ||
              p.name.toLowerCase().contains('rau') ||
              p.name.toLowerCase().contains('củ'))
          .toList();
      if (matchedProducts.isEmpty) {
        matchedProducts = allProducts.take(3).toList();
      }
    } else if (lower.contains('trái cây') ||
        lower.contains('hoa quả') ||
        lower.contains('quả') ||
        lower.contains('trái')) {
      replyText = '🍎 **Trái cây mọng nước, ngọt mát:**\n\n'
          'Bổ sung Vitamin tự nhiên mỗi ngày giúp cơ thể luôn tươi trẻ năng động!';
      matchedProducts = allProducts
          .where((p) =>
              p.categoryId == 'fruit' ||
              p.name.toLowerCase().contains('táo') ||
              p.name.toLowerCase().contains('cam') ||
              p.name.toLowerCase().contains('nho'))
          .toList();
      if (matchedProducts.isEmpty) {
        matchedProducts = allProducts.take(3).toList();
      }
    } else if (lower.contains('thịt') ||
        lower.contains('cá') ||
        lower.contains('protein') ||
        lower.contains('đạm')) {
      replyText = '🥩 **Thực phẩm giàu Protein chất lượng cao:**\n\n'
          'Cung cấp năng lượng tuyệt vời cho các hoạt động thể thao và làm việc hàng ngày!';
      matchedProducts = allProducts
          .where((p) =>
              p.categoryId == 'meat' ||
              p.categoryId == 'seafood' ||
              p.name.toLowerCase().contains('thịt') ||
              p.name.toLowerCase().contains('cá'))
          .toList();
      if (matchedProducts.isEmpty) {
        matchedProducts = allProducts.take(3).toList();
      }
    } else if (lower.contains('rẻ') ||
        lower.contains('giảm giá') ||
        lower.contains('khuyến mãi') ||
        lower.contains('tiết kiệm')) {
      replyText = '🏷️ **Sản phẩm giá tốt ưu đãi hôm nay:**\n\n'
          'Các mặt hàng tươi ngon với mức giá hấp dẫn nhất dành riêng cho bạn!';
      matchedProducts = allProducts
          .where((p) =>
              (p.originalPrice != null && p.originalPrice! > p.price) ||
              p.price < 50000)
          .toList();
      if (matchedProducts.isEmpty) {
        matchedProducts = allProducts.take(3).toList();
      }
    } else {
      // Tìm theo từ khóa
      matchedProducts = allProducts.where((p) {
        return lower.split(' ').any(
            (word) => word.length > 2 && p.name.toLowerCase().contains(word));
      }).toList();

      if (matchedProducts.isNotEmpty) {
        replyText =
            '🔍 Tôi đã tìm thấy các sản phẩm phù hợp với yêu cầu "$input" của bạn:';
      } else {
        replyText =
            '🤖 Tôi hiểu rồi! Bạn có muốn tôi gợi ý các món ăn ngon hoặc sản phẩm tươi sạch hàng đầu tại cửa hàng hôm nay không?';
        matchedProducts = allProducts.take(3).toList();
      }
    }

    return ChatMessageModel(
      id: const Uuid().v4(),
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedProducts:
          matchedProducts.isNotEmpty ? matchedProducts.take(4).toList() : null,
      quickReplies: ['Gợi ý món khác', 'Rau củ tươi', 'Trái cây nhập khẩu'],
    );
  }

  void addToCart(ProductModel product) {
    _cartController.addToCart(product);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
