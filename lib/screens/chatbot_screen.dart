import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:prm_project/model/dto/request/conversation_request.dart';
import 'package:prm_project/model/dto/response/conversation_response.dart';
import 'package:prm_project/services/chat_service.dart';

class ChatBotScreen extends StatefulWidget {
  final String token;
  final String currentUserId;

  const ChatBotScreen({
    super.key,
    required this.token,
    required this.currentUserId,
  });

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final ApiChatService _chatService = ApiChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessageResponse> _messages = [];
  bool _isLoading = true;
  bool _isConnected = false;
  bool _isTransferring = false;
  bool _showQuickQuestions = true;

  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      debugPrint(
        '[ChatBotScreen] 🔄 Initializing chat for ${widget.currentUserId}',
      );
      await _chatService.connectSignalR(widget.token);

      _chatService.setEventHandlers(
        onMessageReceived: _onMessageReceived,
        onUserTyping: (data) => debugPrint('[ChatBotScreen] 🟡 Typing: $data'),
        onStaffAssigned: (data) {
          debugPrint('[ChatBotScreen] 👨‍💼 Staff assigned: $data');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bạn đã được gán nhân viên hỗ trợ')),
          );
        },
      );

      final conv = await _createOrGetMyConversation();
      _conversationId = conv.id;

      await _chatService.joinConversation(_conversationId!);
      setState(() => _isConnected = true);

      final msgs = await _chatService.getMessages(_conversationId!);
      msgs.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));
      if (msgs.isEmpty) {
        msgs.add(
          MessageResponse(
            id: '',
            conversationId: _conversationId!,
            isRead: false,
            senderId: 'ai-bot',
            senderName: 'AI Assistant',
            senderType: 2,
            content:
                'Xin chào bạn 👋! Tôi là trợ lý ảo của trung tâm, bạn cần hỗ trợ gì hôm nay?',
            timestamp: DateTime.now().toIso8601String(),
          ),
        );
      }
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('[ChatBotScreen] ❌ Error initializing chat: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<ConversationResponse> _createOrGetMyConversation() async {
    try {
      final list = await _chatService.getMyConversations();
      if (list.isNotEmpty) {
        debugPrint('[ChatBotScreen] ✅ Dùng conversation cũ: ${list.first.id}');
        setState(() {
          _showQuickQuestions = false;
        });
        return list.first;
      }

      debugPrint('[ChatBotScreen] 🆕 Không có conversation, tạo mới...');
      final newConv = await _chatService.createConversation(
        CreateConversationRequest(
          customerId: widget.currentUserId,
          customerName: widget.currentUserId,
          type: 0,
          initialMessage:
              'Xin chào bạn 👋! Tôi là trợ lý ảo của trung tâm, bạn cần hỗ trợ gì hôm nay?',
        ),
      );
      debugPrint('[ChatBotScreen] ✅ Conversation mới: ${newConv.id}');

      // Tạo lời chào mặc định của AI và gán vào state
      final welcome = MessageResponse(
        id: '',
        conversationId: newConv.id ?? '',
        isRead: false,
        senderId: 'ai-bot',
        senderName: 'AI Assistant',
        senderType: 2,
        content:
            'Xin chào bạn 👋! Tôi là trợ lý ảo của trung tâm, bạn cần hỗ trợ gì hôm nay?',
        timestamp: DateTime.now().toIso8601String(),
      );

      setState(() {
        _messages = [welcome];
      });

      return newConv;
    } catch (e) {
      debugPrint('[ChatBotScreen] ❌ Lỗi khi tạo/lấy conversation: $e');
      rethrow;
    }
  }

  // Tạo đoạn chat mới
  Future<void> _createNewConversation() async {
    try {
      setState(() {
        _isLoading = true;
        _messages.clear();
        _showQuickQuestions = true;
      });

      final newConv = await _chatService.createConversation(
        CreateConversationRequest(
          customerId: widget.currentUserId,
          customerName: widget.currentUserId,
          type: 0,
        ),
      );

      debugPrint('[ChatBotScreen] 🆕 New conversation: ${newConv.id}');
      _conversationId = newConv.id;

      await _chatService.joinConversation(_conversationId!);

      // Thêm lời chào mặc định của AI
      final welcome = MessageResponse(
        id: '',
        conversationId: newConv.id ?? '',
        isRead: false,
        senderId: 'ai-bot',
        senderName: 'AI Assistant',
        senderType: 2,
        content:
            'Xin chào bạn 👋! Tôi là trợ lý ảo của trung tâm, bạn cần hỗ trợ gì hôm nay?',
        timestamp: DateTime.now().toIso8601String(),
      );

      setState(() {
        _messages = [welcome];
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('[ChatBotScreen] ❌ Tạo đoạn chat mới thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tạo đoạn chat mới 😢')),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onMessageReceived(MessageResponse msg) {
    debugPrint('[ChatBotScreen] 💬 Received: ${msg.content}');
    setState(() => _messages.add(msg));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    try {
      await _chatService.sendMessage(_conversationId!, text);
      setState(() {
        _showQuickQuestions = false;
      });
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('[ChatBotScreen] ❌ Send message failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không gửi được tin nhắn 😢')),
      );
    }
  }

  Future<void> _transferToStaff() async {
    if (_isTransferring || _conversationId == null) return;
    setState(() => _isTransferring = true);

    try {
      await _chatService.requestTransferToStaff(_conversationId!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã gửi yêu cầu chuyển sang nhân viên'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('[ChatBotScreen] ❌ Transfer failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không thể chuyển sang nhân viên'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => _isTransferring = false);
    }
  }

  @override
  void dispose() {
    _chatService.disconnectSignalR();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Trợ lý khách hàng'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          actions: [
            IconButton(
              tooltip: 'Tạo đoạn chat mới',
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: _createNewConversation,
            ),
            if (_isConnected)
              IconButton(
                onPressed: _isTransferring ? null : _transferToStaff,
                tooltip: 'Chuyển sang nhân viên hỗ trợ',
                icon: _isTransferring
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.support_agent),
              ),
          ],
        ),
        body: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _conversationId == null
                          ? '📜 Đang tải lịch sử chat của bạn...'
                          : '🔄 Đang khởi tạo trợ lý ảo cho bạn...',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMine = msg.senderId == widget.currentUserId;
                        final int? senderType = msg.senderType;

                        Color bubbleColor;
                        String senderLabel;
                        IconData senderIcon;

                        switch (senderType) {
                          case 0:
                            bubbleColor = theme.colorScheme.primaryContainer;
                            senderLabel = isMine
                                ? 'Bạn'
                                : (msg.senderName ?? 'Khách hàng');
                            senderIcon = Icons.person;
                            break;
                          case 1:
                            bubbleColor = Colors.orangeAccent.shade100;
                            senderLabel = 'Nhân viên hỗ trợ';
                            senderIcon = Icons.support_agent;
                            break;
                          case 2:
                            bubbleColor = Colors.greenAccent.shade100;
                            senderLabel = 'AI Assistant';
                            senderIcon = Icons.smart_toy;
                            break;
                          default:
                            bubbleColor = Colors.grey.shade300;
                            senderLabel = 'Hệ thống';
                            senderIcon = Icons.settings;
                        }

                        bool showSenderHeader = true;
                        if (index > 0) {
                          final prevMsg = _messages[index - 1];
                          if (prevMsg.senderType == msg.senderType &&
                              prevMsg.senderId == msg.senderId) {
                            showSenderHeader = false;
                          }
                        }

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: showSenderHeader ? 12 : 4,
                              left: isMine ? 60 : 12,
                              right: isMine ? 12 : 60,
                            ),
                            child: Column(
                              crossAxisAlignment: isMine
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (showSenderHeader && !isMine)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        senderIcon,
                                        size: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        senderLabel,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    color: bubbleColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(12),
                                      topRight: const Radius.circular(12),
                                      bottomLeft: Radius.circular(
                                        isMine ? 12 : 0,
                                      ),
                                      bottomRight: Radius.circular(
                                        isMine ? 0 : 12,
                                      ),
                                    ),
                                  ),
                                  child: MarkdownBody(
                                    data: msg.content ?? '',
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(
                                        fontSize: 15,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      strong: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      listBullet: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  Container(
                    color: theme.colorScheme.surface,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Các câu hỏi mẫu
                        if (_showQuickQuestions)
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                label: const Text("Bảng giá dịch vụ"),
                                onPressed: () {
                                  _messageController.text = "Bảng giá dịch vụ";
                                  _sendMessage(); // gửi luôn và ẩn chip
                                },
                              ),
                              ActionChip(
                                label: const Text("Chi phí thay thế linh kiện"),
                                onPressed: () {
                                  _messageController.text =
                                      "Chi phí thay thế linh kiện";
                                  _sendMessage();
                                },
                              ),
                              ActionChip(
                                label: const Text("Ưu đãi / Khuyến mãi"),
                                onPressed: () {
                                  _messageController.text =
                                      "Ưu đãi / Khuyến mãi";
                                  _sendMessage();
                                },
                              ),
                              ActionChip(
                                label: const Text("Tư vấn lỗi xe"),
                                onPressed: () {
                                  _messageController.text = "Tư vấn lỗi xe";
                                  _sendMessage();
                                },
                              ),
                              ActionChip(
                                label: const Text("Hướng dẫn sử dụng app"),
                                onPressed: () {
                                  _messageController.text =
                                      "Hướng dẫn sử dụng app";
                                  _sendMessage();
                                },
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        // Thanh nhập tin nhắn
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Nhập tin nhắn...',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _sendMessage,
                              icon: Icon(
                                Icons.send,
                                color: theme.colorScheme.primary,
                              ),
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
  }
}
