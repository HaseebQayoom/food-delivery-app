import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:food_delivery/core/constants/env.dart';
import 'package:food_delivery/models/chat_message_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatState {
  final List<ChatMessageModel> messages;
  final bool isTyping;

  const ChatState({this.messages = const [], this.isTyping = false});

  ChatState copyWith({List<ChatMessageModel>? messages, bool? isTyping}) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  ChatState addMessage(ChatMessageModel msg) {
    return copyWith(messages: [...messages, msg]);
  }
}

class ChatNotifier extends Notifier<ChatState> {
  late final ChatSession _session;

  @override
  ChatState build() {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Env.geminiApiKey,
      systemInstruction: Content.system(
        'You are a friendly support assistant for "crave." — a food delivery app in Pakistan. '
        'Help users with order tracking, cancellations, payment issues, and general questions. '
        'Be concise, warm, and helpful. Use Pakistani context (Rs currency, Lahore/Karachi etc.). '
        'If unsure, politely escalate to human support.',
      ),
    );
    _session = model.startChat();

    final greeting = ChatMessageModel(
      id: '0',
      text: 'Hi! 👋 I\'m your Crave assistant. How can I help you today?',
      isFromUser: false,
      sentAt: DateTime.now(),
      quickReplies: ['Track my order', 'Cancel order', 'Payment issue', 'Other'],
    );

    return ChatState(messages: [greeting]);
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
      final response = await _session.sendMessage(Content.text(text));
      final replyText = response.text ?? 'Sorry, I couldn\'t process that. Please try again.';

      final botMsg = ChatMessageModel(
        id: '${DateTime.now().microsecondsSinceEpoch}b',
        text: replyText,
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
