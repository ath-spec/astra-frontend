import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';
import '../models/chat_message.dart';
import '../services/demo_ai_service.dart';
import 'chat_session_provider.dart';
import '../../auth/providers/auth_provider.dart';

part 'chat_provider.g.dart';

@riverpod
class IsSpeaking extends _$IsSpeaking {
  @override
  bool build() => false;
  
  void setSpeaking(bool value) => state = value;
}

@riverpod
class IsProcessing extends _$IsProcessing {
  @override
  bool build() => false;
  
  void setProcessing(bool value) => state = value;
}

@riverpod
class IsTyping extends _$IsTyping {
  @override
  bool build() => false;
  
  void setTyping(bool value) => state = value;
}

@Riverpod(keepAlive: true)
class ChatNotifier extends _$ChatNotifier {
  final _uuid = const Uuid();
  final _aiService = DemoAIService();
  String _currentSessionId = const Uuid().v4();
  bool _isCancelled = false;

  @override
  List<ChatMessage> build() {
    // Listen to audio player state
    _aiService.audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      
      if (processingState == ProcessingState.completed) {
        ref.read(isSpeakingProvider.notifier).setSpeaking(false);
      } else {
        ref.read(isSpeakingProvider.notifier).setSpeaking(isPlaying);
      }
    });
    
    return [];
  }

  void _saveSession() {
    ref.read(chatSessionManagerProvider.notifier).saveSession(_currentSessionId, state);
  }

  void startNewSession() {
    _currentSessionId = _uuid.v4();
    state = [];
  }

  void loadSession(String sessionId) {
    final session = ref.read(chatSessionManagerProvider.notifier).getSession(sessionId);
    if (session != null) {
      _currentSessionId = sessionId;
      state = session.messages;
    }
  }

  void addMessages(List<ChatMessage> messages) {
    state = [...state, ...messages];
    _saveSession();
  }
  
  void stopSpeaking() {
    _aiService.stopSpeaking();
  }

  void cancelGeneration() {
    _isCancelled = true;
    _aiService.stopSpeaking();
    ref.read(isProcessingProvider.notifier).setProcessing(false);
    ref.read(isTypingProvider.notifier).setTyping(false);
    
    // Mark last AI message as interrupted using a zero-width space so the UI can stop the typewriter animation
    if (state.isNotEmpty && !state.last.isUser) {
        final lastMsg = state.last;
        if (!lastMsg.text.endsWith('\u200B')) {
            final updatedMsg = ChatMessage(
                id: lastMsg.id,
                text: '${lastMsg.text}\u200B',
                isUser: false,
                timestamp: lastMsg.timestamp,
            );
            state = [...state.sublist(0, state.length - 1), updatedMsg];
            _saveSession();
        }
    }
  }

  Future<void> sendMessage(String text, {bool isVoice = true}) async {
    if (text.trim().isEmpty) return;

    // Immediately stop any currently playing AI audio when a new message is sent
    _aiService.stopSpeaking();

    _isCancelled = false;
    ref.read(isProcessingProvider.notifier).setProcessing(true);

    // Add user message
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMsg];
    _saveSession();

    // Build message history for the AI (send only the last 4 messages for context)
    final recentMessages = state.length > 4 ? state.sublist(state.length - 4) : state;
    final messageHistory = recentMessages.map((m) => {
      'role': m.isUser ? 'user' : 'assistant',
      'content': m.text,
    }).toList();

    try {
      final authState = ref.read(authProvider);
      String phone = '+919876543210';
      String name = 'Judge';
      
      if (authState is AuthAuthenticated) {
        phone = authState.user.email.replaceAll('@astra.dev', '');
        name = authState.user.name;
      }

      // Fetch response from Groq
      final responseText = await _aiService.getChatResponse(messageHistory, phone: phone, name: name);
      
      if (_isCancelled) return;
      
      if (isVoice) {
        String spokenText = responseText.replaceAll(RegExp(r'```json[\s\S]*?```'), '');
        spokenText = spokenText.replaceAll(RegExp(r'\|.*\|'), '');
        spokenText = spokenText.replaceAll(RegExp(r'[-*#_~`]'), '');
        spokenText = spokenText.replaceAll(RegExp(r'\n+'), ' ').trim();

        if (spokenText.isNotEmpty) {
          await _aiService.speak(spokenText);
        }
      }
      
      if (_isCancelled) return;

      final aiMsg = ChatMessage(
        id: _uuid.v4(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, aiMsg];
      _saveSession();
      
      // Response received and audio generated, go back to normal
      ref.read(isProcessingProvider.notifier).setProcessing(false);

      // Only play voice if requested is now handled above
    } catch (e) {
      ref.read(isProcessingProvider.notifier).setProcessing(false);
      
      if (!_isCancelled) {
        // Clean up the Exception: prefix if it exists
        String errorText = e.toString();
        if (errorText.startsWith('Exception: ')) {
          errorText = errorText.substring(11);
        } else {
          errorText = 'I apologize, but I encountered an error connecting to my servers. Please try again.';
        }

        final errorMsg = ChatMessage(
          id: _uuid.v4(),
          text: errorText,
          isUser: false,
          timestamp: DateTime.now(),
        );
        state = [...state, errorMsg];
      }
    }
  }

  void loadDummyThread(String title) {
    startNewSession();
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: 'Tell me about $title',
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = [userMsg];
    _saveSession();
    
    // Then trigger a real message flow
    sendMessage('Tell me about $title');
  }
}
