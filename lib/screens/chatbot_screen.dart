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

      // 1️⃣ Kết nối SignalR
      await _chatService.connectSignalR(widget.token);

      // 2️⃣ Đăng ký sự kiện (chỉ 1 lần, sau khi connect)
      _chatService.setEventHandlers(
        onMessageReceived: _onMessageReceived,
        onUserTyping: (data) => debugPrint('[ChatBotScreen] 🟡 Typing: $data'),
        onStaffAssigned: (data) {
          debugPrint('[ChatBotScreen] 👨‍💼 Staff assigned: $data');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Bạn đã được gán nhân viên hỗ trợ')),
            );
          }
        },
      );

      // 3️⃣ Tạo hoặc lấy conversation
      final conv = await _createOrGetMyConversation();
      _conversationId = conv.id;

      // 4️⃣ Join vào group SignalR
      await _chatService.joinConversation(_conversationId!);
      setState(() => _isConnected = true);

      // 5️⃣ Load lịch sử tin nhắn
      final msgs = await _chatService.getMessages(_conversationId!);
      msgs.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

      // Nếu trống → thêm tin nhắn chào
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

      if (mounted) {
        setState(() {
          _messages = msgs;
          _isLoading = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      debugPrint('[ChatBotScreen] ❌ Error initializing chat: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<ConversationResponse> _createOrGetMyConversation() async {
    try {
      final list = await _chatService.getMyConversations();
      if (list.isNotEmpty) {
        debugPrint('[ChatBotScreen] Dùng conversation cũ: ${list.first.id}');
        setState(() => _showQuickQuestions = false);
        return list.first;
      }

      debugPrint('[ChatBotScreen] Không có conversation, tạo mới...');
      final newConv = await _chatService.createConversation(
        CreateConversationRequest(
          customerId: widget.currentUserId,
          customerName: widget.currentUserId,
          type: 0,
        ),
      );
      debugPrint('[ChatBotScreen] Conversation mới: ${newConv.id}');
      return newConv;
    } catch (e) {
      debugPrint('[ChatBotScreen] Lỗi khi tạo/lấy conversation: $e');
      rethrow;
    }
  }

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

      _conversationId = newConv.id;
      await _chatService.joinConversation(_conversationId!);

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

      if (mounted) {
        setState(() {
          _messages = [welcome];
          _isLoading = false;
        });
      }

      _scrollToBottom();
    } catch (e) {
      debugPrint('[ChatBotScreen] Tạo đoạn chat mới thất bại: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tạo đoạn chat mới 😢')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ Cập nhật lại: tránh mutate list cũ
  void _onMessageReceived(MessageResponse msg) {
    debugPrint('[ChatBotScreen] 💬 Received: ${msg.content}');
    if (!mounted) return;
    setState(() {
      _messages = List.from(_messages)..add(msg);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
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
      if (mounted) {
        setState(() => _showQuickQuestions = false);
      }
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('[ChatBotScreen] Send message failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không gửi được tin nhắn 😢')),
        );
      }
    }
  }

  Future<void> _transferToStaff() async {
    if (_isTransferring || _conversationId == null) return;
    setState(() => _isTransferring = true);

    try {
      await _chatService.requestTransferToStaff(_conversationId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu chuyển sang nhân viên')),
        );
      }
    } catch (e) {
      debugPrint('[ChatBotScreen] Transfer failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể chuyển sang nhân viên')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTransferring = false);
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
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('🔄 Đang khởi tạo trợ lý ảo cho bạn...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // 📜 DANH SÁCH TIN NHẮN
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMine = msg.senderId == widget.currentUserId;
                        final senderType = msg.senderType;

                        // Tin nhắn hệ thống
                        if (senderType == 3) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg.content ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        // Tin nhắn AI, nhân viên, khách hàng
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
                            senderLabel = 'Người gửi';
                            senderIcon = Icons.person_outline;
                        }

                        bool showHeader = true;
                        if (index > 0) {
                          final prev = _messages[index - 1];
                          if (prev.senderType == msg.senderType &&
                              prev.senderId == msg.senderId) {
                            showHeader = false;
                          }
                        }

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: showHeader ? 12 : 4,
                              left: isMine ? 60 : 12,
                              right: isMine ? 12 : 60,
                            ),
                            child: Column(
                              crossAxisAlignment: isMine
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (showHeader && !isMine)
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

                  // Ô nhập tin nhắn + Quick actions
                  Container(
                    color: theme.colorScheme.surface,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_showQuickQuestions)
                          Wrap(
                            spacing: 8,
                            children: [
                              _quickChip("Bảng giá dịch vụ"),
                              _quickChip("Chi phí thay thế linh kiện"),
                              _quickChip("Ưu đãi / Khuyến mãi"),
                              _quickChip("Tư vấn lỗi xe"),
                              _quickChip("Hướng dẫn sử dụng app"),
                            ],
                          ),
                        const SizedBox(height: 8),
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

  Widget _quickChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
    );
  }
}
