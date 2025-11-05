class CreateConversationRequest {
  final String customerId;
  final String customerName;
  final int type;
  final String? initialMessage;

  CreateConversationRequest({
    required this.customerId,
    required this.customerName,
    required this.type,
    this.initialMessage,
  });

  Map<String, dynamic> toJson() => {
    'customerId': customerId,
    'customerName': customerName,
    'type': type,
    if (initialMessage != null) 'initialMessage': initialMessage,
  };
}
