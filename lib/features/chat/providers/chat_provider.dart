import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

part 'chat_provider.g.dart';

@Riverpod(keepAlive: true)
class ChatNotifier extends _$ChatNotifier {
  final _uuid = const Uuid();

  @override
  List<ChatMessage> build() {
    return [];
  }

  void addMessages(List<ChatMessage> messages) {
    state = [...state, ...messages];
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

  void loadDummyThread(String title) {
    final msgs = List.generate(12, (i) => ChatMessage(
      id: _uuid.v4(),
      text: i == 0 
          ? 'Tell me about $title' 
          : i.isEven 
              ? 'Could you elaborate on how that affects my specific portfolio?' 
              : 'Based on our analysis of $title, this represents a significant opportunity. Your current exposure is 15%, and we recommend rebalancing.',
      isUser: i.isEven,
      timestamp: DateTime.now().subtract(Duration(minutes: 12 - i)),
    ));
    state = msgs;
  }
}
