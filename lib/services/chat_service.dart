import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/io_client.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:dio/dio.dart';

import 'api_service.dart';
import 'package:prm_project/model/dto/request/conversation_request.dart';
import 'package:prm_project/model/dto/response/conversation_response.dart';

class ApiChatService {
  final _api = ApiService();
  HubConnection? _hubConnection;

  //Base URL cho ChatHub (ví dụ: https://192.168.1.10:7200)
  String get _baseUrl => dotenv.env['CHAT_HUB_URL'] ?? '';

  ///Bypass SSL khi chạy local (cho phép mobile kết nối tới localhost)
  IOClient createBypassClient() {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(ioClient);
  }

  Future<List<ConversationResponse>> getMyConversations() async {
    try {
      final res = await _api.get('/Conversations/my');
      final data = res.data;
      if (data is List) {
        return data.map((e) => ConversationResponse.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      print(
        '[ApiChatService] getMyConversations error: ${e.response?.statusCode}',
      );
      rethrow;
    }
  }

  Future<ConversationResponse> createConversation(
    CreateConversationRequest req,
  ) async {
    try {
      final res = await _api.post('/Conversations', data: req.toJson());
      return ConversationResponse.fromJson(res.data);
    } on DioException catch (e) {
      print(
        '[ApiChatService] createConversation error: ${e.response?.statusCode}',
      );
      rethrow;
    }
  }

  Future<List<MessageResponse>> getMessages(String conversationId) async {
    try {
      final res = await _api.get('/Conversations/$conversationId/messages');
      final data = res.data;
      if (data is List) {
        return data.map((e) => MessageResponse.fromJson(e)).toList();
      } else {
        throw Exception('Invalid response format');
      }
    } on DioException catch (e) {
      print('[ApiChatService] getMessages error: ${e.response?.statusCode}');
      rethrow;
    }
  }

  Future<void> connectSignalR(String token) async {
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.connected) {
      print('[ApiChatService] Already connected to SignalR');
      return;
    }

    final hubUrl = '$_baseUrl/chathub';
    print('[ApiChatService] Connecting to SignalR hub: $hubUrl');

    final client = createBypassClient();

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          HttpConnectionOptions(
            client: client,
            accessTokenFactory: () async => token,
            transport: HttpTransportType.webSockets,
            logging: (level, message) => print('[SignalR] $message'),
          ),
        )
        .withAutomaticReconnect()
        .build();

    _registerEvents();

    _hubConnection!.onclose((error) {
      print('[SignalR] Disconnected: $error');
    });

    _hubConnection!.onreconnecting((error) {
      print('[SignalR] Reconnecting... $error');
    });

    _hubConnection!.onreconnected((connectionId) {
      print('[SignalR] Reconnected with connectionId: $connectionId');
    });

    await _hubConnection!.start();
    print('[SignalR] Connected successfully');
  }

  void _registerEvents() {
    if (_hubConnection == null) return;

    _hubConnection!.on('ReceiveMessage', (args) {
      if (args != null && args.isNotEmpty) {
        final message = MessageResponse.fromJson(args[0]);
        print('[SignalR] 💬 New message from ${message.senderName}');
        _onMessageReceived?.call(message);
      }
    });

    _hubConnection!.on('UserTyping', (args) {
      print('[SignalR] UserTyping: $args');
      if (args != null && args.isNotEmpty) {
        _onUserTyping?.call(args[0]);
      }
    });

    _hubConnection!.on('TransferRequested', (args) {
      print('[SignalR] TransferRequested: $args');
      if (args != null && args.isNotEmpty) {
        _onTransferRequested?.call(args[0]);
      }
    });

    _hubConnection!.on('StaffAssigned', (args) {
      print('[SignalR] StaffAssigned: $args');
      if (args != null && args.isNotEmpty) {
        _onStaffAssigned?.call(args[0]);
      }
    });

    _hubConnection!.on('ConversationAssigned', (args) {
      print('[SignalR] ConversationAssigned: $args');
      if (args != null && args.isNotEmpty) {
        _onConversationAssigned?.call(args[0]);
      }
    });

    _hubConnection!.on('NewWaitingConversation', (args) {
      print('[SignalR] NewWaitingConversation: $args');
      if (args != null && args.isNotEmpty) {
        _onNewWaitingConversation?.call(args[0]);
      }
    });

    _hubConnection!.on('UserJoinedConversation', (args) {
      print('[SignalR] UserJoinedConversation: $args');
      if (args != null && args.isNotEmpty) {
        _onUserJoinedConversation?.call(args[0]);
      }
    });

    _hubConnection!.on('UserLeftConversation', (args) {
      print('[SignalR] UserLeftConversation: $args');
      if (args != null && args.isNotEmpty) {
        _onUserLeftConversation?.call(args[0]);
      }
    });
  }

  Future<void> joinConversation(String conversationId) async {
    await _hubConnection?.invoke('JoinConversation', args: [conversationId]);
  }

  Future<void> leaveConversation(String conversationId) async {
    await _hubConnection?.invoke('LeaveConversation', args: [conversationId]);
  }

  Future<void> sendMessage(String conversationId, String content) async {
    await _hubConnection?.invoke(
      'SendMessage',
      args: [
        {'conversationId': conversationId, 'content': content},
      ],
    );
  }

  Future<void> setTyping(String conversationId, bool isTyping) async {
    await _hubConnection?.invoke('Typing', args: [conversationId, isTyping]);
  }

  Future<void> requestTransferToStaff(String conversationId) async {
    await _hubConnection?.invoke(
      'RequestTransferToStaff',
      args: [conversationId],
    );
  }

  // Lấy conversation theo ID
  Future<ConversationResponse> getConversation(String conversationId) async {
    try {
      final res = await _api.get('/Conversations/$conversationId');
      return ConversationResponse.fromJson(res.data);
    } on DioException catch (e) {
      print(
        '[ApiChatService] getConversation error: ${e.response?.statusCode}',
      );
      rethrow;
    }
  }

  // Request chuyển sang nhân viên (Transfer)
  Future<void> requestTransferToStaffApi(String conversationId) async {
    try {
      await _api.post('/Conversations/$conversationId/request-staff');
    } on DioException catch (e) {
      print(
        '[ApiChatService] requestTransferToStaffApi error: ${e.response?.statusCode}',
      );
      rethrow;
    }
  }

  Future<void> assignStaffToConversation(
    String conversationId,
    String staffId,
    String staffName,
  ) async {
    await _hubConnection?.invoke(
      'AssignStaffToConversation',
      args: [conversationId, staffId, staffName],
    );
  }

  Future<void> disconnectSignalR() async {
    if (_hubConnection != null) {
      await _hubConnection!.stop();
      print('[SignalR] Connection stopped');
    }
  }

  Function(MessageResponse)? _onMessageReceived;
  Function(dynamic)? _onUserTyping;
  Function(dynamic)? _onTransferRequested;
  Function(dynamic)? _onStaffAssigned;
  Function(dynamic)? _onConversationAssigned;
  Function(dynamic)? _onNewWaitingConversation;
  Function(dynamic)? _onUserJoinedConversation;
  Function(dynamic)? _onUserLeftConversation;

  void setEventHandlers({
    Function(MessageResponse)? onMessageReceived,
    Function(dynamic)? onUserTyping,
    Function(dynamic)? onTransferRequested,
    Function(dynamic)? onStaffAssigned,
    Function(dynamic)? onConversationAssigned,
    Function(dynamic)? onNewWaitingConversation,
    Function(dynamic)? onUserJoinedConversation,
    Function(dynamic)? onUserLeftConversation,
  }) {
    _onMessageReceived = onMessageReceived ?? _onMessageReceived;
    _onUserTyping = onUserTyping ?? _onUserTyping;
    _onTransferRequested = onTransferRequested ?? _onTransferRequested;
    _onStaffAssigned = onStaffAssigned ?? _onStaffAssigned;
    _onConversationAssigned = onConversationAssigned ?? _onConversationAssigned;
    _onNewWaitingConversation =
        onNewWaitingConversation ?? _onNewWaitingConversation;
    _onUserJoinedConversation =
        onUserJoinedConversation ?? _onUserJoinedConversation;
    _onUserLeftConversation = onUserLeftConversation ?? _onUserLeftConversation;
  }
}
