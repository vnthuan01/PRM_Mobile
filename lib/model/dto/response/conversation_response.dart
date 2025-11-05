class ConversationResponse {
  final String id;
  final String customerId;
  final String customerName;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final int status;
  final int type;
  final String createdAt;
  final String updatedAt;
  final String? lastMessage;
  final String? lastMessageAt;
  final int unreadCount;

  ConversationResponse({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.assignedStaffId,
    this.assignedStaffName,
    required this.status,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) =>
      ConversationResponse(
        id: json['id'],
        customerId: json['customerId'],
        customerName: json['customerName'],
        assignedStaffId: json['assignedStaffId'],
        assignedStaffName: json['assignedStaffName'],
        status: json['status'],
        type: json['type'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        lastMessage: json['lastMessage'],
        lastMessageAt: json['lastMessageAt'],
        unreadCount: json['unreadCount'] ?? 0,
      );
}

class MessageResponse {
  final String? id;
  final String conversationId;
  final String content;
  final String senderId;
  final String senderName;
  final int senderType;
  final String timestamp;
  final bool isRead;

  MessageResponse({
    this.id,
    required this.conversationId,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    required this.timestamp,
    required this.isRead,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        id: json['id'],
        conversationId: json['conversationId'],
        content: json['content'],
        senderId: json['senderId'],
        senderName: json['senderName'],
        senderType: json['senderType'],
        timestamp: json['timestamp'],
        isRead: json['isRead'] ?? false,
      );
}
