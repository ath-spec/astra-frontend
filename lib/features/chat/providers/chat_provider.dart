import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

part 'chat_provider.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  final _uuid = const Uuid();

  @override
  List<ChatMessage> build() {
    return [];
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMsg];

    // Simulate AI response delay
    Future.delayed(const Duration(seconds: 1), () {
      final aiMsg = ChatMessage(
        id: _uuid.v4(),
        text: 'I can help you with that. We are currently processing your request and analyzing your cash position.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, aiMsg];
    });
  }
}
