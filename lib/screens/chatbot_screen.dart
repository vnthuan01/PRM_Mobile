import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  // Câu hỏi gợi ý
  final List<String> _suggestedQuestions = [
    "Bao lâu nên bảo dưỡng xe một lần?",
    "Xe tôi có tiếng ồn lạ, nguyên nhân?",
    "Làm sao kiểm tra dầu phanh?",
    "Chi phí sửa chữa định kỳ?",
  ];

  // Thay endpoint API ở đây
  final String apiUrl = "https://example.com/chat";

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
    });

    _controller.clear();

    // Gọi API
    String botReply = await _getBotResponseFromApi(text);

    setState(() {
      _messages.add(_ChatMessage(text: botReply, isUser: false));
    });

    // Auto scroll xuống cuối
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String> _getBotResponseFromApi(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Giả sử API trả về { "reply": "Nội dung trả lời" }
        return data['reply'] ?? "Xin lỗi, mình chưa hiểu câu hỏi.";
      } else {
        return "Có lỗi xảy ra khi gọi API.";
      }
    } catch (e) {
      return "Không thể kết nối server: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userBubbleColor = theme.colorScheme.primary;
    final botBubbleColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final backgroundColor = theme.colorScheme.background;
    final inputBackground = isDark ? Colors.grey[900]! : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("Chatbot Tư vấn Xe"),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: msg.isUser ? userBubbleColor : botBubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!msg.isUser) ...[
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              child: Icon(
                                Icons.smart_toy,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser
                                    ? theme
                                          .colorScheme
                                          .onPrimary // màu chữ user
                                    : theme
                                          .colorScheme
                                          .onSurface, // màu chữ bot theo theme
                              ),
                            ),
                          ),

                          if (msg.isUser) ...[
                            const SizedBox(width: 8),
                            const CircleAvatar(
                              radius: 14,
                              child: Icon(Icons.person, size: 16),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Suggested questions
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: _suggestedQuestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final q = _suggestedQuestions[index];
                  return ActionChip(
                    label: Text(q, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _sendMessage(q),
                  );
                },
              ),
            ),

            // Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: inputBackground,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Nhập câu hỏi...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: theme.colorScheme.primary),
                    onPressed: () => _sendMessage(_controller.text),
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

class _ChatMessage {
  final String text;
  final bool isUser;

  _ChatMessage({required this.text, required this.isUser});
}
