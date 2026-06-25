import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/env.dart';
import 'package:food_delivery/models/chat_message_model.dart';
import 'package:food_delivery/repositories/order_repository.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isTyping;
  final String _orderContext;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    String orderContext = '',
  }) : _orderContext = orderContext;

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    bool? isTyping,
    String? orderContext,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        orderContext: orderContext ?? _orderContext,
      );

  ChatState addMessage(ChatMessageModel msg) =>
      copyWith(messages: [...messages, msg]);
}

class ChatNotifier extends Notifier<ChatState> {
  final _dio = Dio();

  @override
  ChatState build() {
    Future.microtask(_loadOrders);
    final greeting = ChatMessageModel(
      id: '0',
      text: 'Hi! 👋 I\'m your Crave assistant. How can I help you today?',
      isFromUser: false,
      sentAt: DateTime.now(),
      quickReplies: ['Track my order', 'Cancel order', 'Payment issue', 'Other'],
    );
    return ChatState(messages: [greeting]);
  }

  Future<void> refreshOrders() => _loadOrders();

  Future<void> _loadOrders() async {
    try {
      final orders = await ref.read(orderRepositoryProvider).getOrderHistory();

      if (orders.isEmpty) {
        state = state.copyWith(orderContext: '');
        return;
      }

      final lines = orders.take(10).map((o) {
        final items = o.items.map((i) => '${i.quantity}x ${i.dish.name}').join(', ');
        final courier = o.courierName != null ? ', Courier: ${o.courierName}' : '';
        return '- Order ID: ${o.id.substring(0, 8)} | '
            'Restaurant: ${o.restaurantName} | '
            'Items: $items | '
            'Status: ${o.status.label} | '
            'Total: Rs ${o.totalRs} | '
            'Address: ${o.deliveryAddress}$courier';
      }).join('\n');

      state = state.copyWith(orderContext: lines);
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      isFromUser: true,
      sentAt: DateTime.now(),
    );

    state = state.addMessage(userMsg).copyWith(isTyping: true);

    try {
      final orderSection = state._orderContext.isNotEmpty
          ? '\n\nUser\'s order history (use this to answer tracking/order questions):\n${state._orderContext}'
          : '\n\nThe user has no orders yet.';

      final systemPrompt =
          'You are a READ-ONLY support assistant for "crave." — a food delivery app in Pakistan. '
          'Keep ALL replies under 3 sentences. Be direct and friendly. '
          'Use Pakistani context (Rs currency). '
          'When asked about orders, use the order data provided — give the exact status and details. '
          'IMPORTANT: You CANNOT place orders, cancel orders, make payments, or take any action in the app. '
          'If asked to place/cancel/modify an order, always say: "I can\'t do that for you — please use the app to place or manage your orders." '
          'Never pretend to perform an action. Only answer questions based on the order data provided. '
          'If you cannot help, say "Please contact our support team."'
          '$orderSection';

      final history = state.messages
          .where((m) => m.id != '0')
          .map((m) => {
                'role': m.isFromUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList();

      final response = await _dio.post(
        'https://api.groq.com/openai/v1/chat/completions',
        options: Options(headers: {
          'Authorization': 'Bearer ${Env.groqApiKey}',
          'Content-Type': 'application/json',
        }),
        data: {
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            ...history,
          ],
          'max_tokens': 150,
        },
      );

      final replyText =
          response.data['choices'][0]['message']['content'] as String? ??
              'Sorry, I couldn\'t process that. Please try again.';

      final botMsg = ChatMessageModel(
        id: '${DateTime.now().microsecondsSinceEpoch}b',
        text: replyText.trim(),
        isFromUser: false,
        sentAt: DateTime.now(),
      );

      state = state.addMessage(botMsg).copyWith(isTyping: false);
    } catch (_) {
      final errorMsg = ChatMessageModel(
        id: '${DateTime.now().microsecondsSinceEpoch}e',
        text: 'Sorry, I\'m having trouble connecting. Please try again later.',
        isFromUser: false,
        sentAt: DateTime.now(),
      );
      state = state.addMessage(errorMsg).copyWith(isTyping: false);
    }
  }
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
