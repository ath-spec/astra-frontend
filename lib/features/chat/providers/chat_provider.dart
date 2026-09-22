import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:just_audio/just_audio.dart';
import '../models/chat_message.dart';
import '../services/demo_ai_service.dart';
import 'chat_session_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../asset_connection/providers/asset_connection_provider.dart';

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

  /// Loads a thread by ID. Checks the local on-device cache first (instant,
  /// covers the common case of reopening a thread from this same session),
  /// then falls back to fetching it from the backend — the real source of
  /// truth now that chat_sessions persists every thread server-side, not
  /// just whatever happens to still be in this device's local storage.
  Future<void> loadSession(String sessionId) async {
    final cached = ref.read(chatSessionManagerProvider.notifier).getSession(sessionId);
    if (cached != null) {
      _currentSessionId = sessionId;
      state = cached.messages;
      return;
    }

    final authState = ref.read(authProvider);
    String phone = '+919876543210';
    String name = 'Judge';
    if (authState is AuthAuthenticated) {
      phone = authState.user.email.replaceAll('@astra.dev', '');
      name = authState.user.name;
    }

    final raw = await _aiService.fetchSessionMessages(phone: phone, name: name, sessionId: sessionId);
    if (raw == null) return; // fetch failed — leave current state alone

    final messages = <ChatMessage>[];
    for (final msg in raw) {
      final role = msg['role'] as String? ?? 'assistant';
      final content = msg['content'] as String? ?? '';
      if (role == 'system' || content.isEmpty) continue;
      messages.add(ChatMessage(
        id: _uuid.v4(),
        text: content,
        isUser: role == 'user',
        timestamp: DateTime.now(),
      ));
    }

    _currentSessionId = sessionId;
    state = messages;
    _saveSession();
  }

  Future<void> initializeHistory() async {
    if (state.isNotEmpty) return; // Already loaded

    final authState = ref.read(authProvider);
    String phone = '+919876543210';
    String name = 'Judge';
    
    if (authState is AuthAuthenticated) {
      phone = authState.user.email.replaceAll('@astra.dev', '');
      name = authState.user.name;
    }

    // Extract Linked Banks from the UI State
    final assetState = ref.read(assetConnectionProvider);
    final linkedBanks = assetState.bankAccounts
        .where((b) => b.isLinked)
        .map((b) => {
              'bankName': b.bankName,
              'accountType': b.accountType.toUpperCase(),
              'balance': b.balance > 0 ? b.balance : 150000.0, // fallback balance if none
            })
        .toList();

    final historyRaw = await _aiService.fetchChatHistory(phone: phone, name: name, banks: linkedBanks);
    
    List<ChatMessage> historyMessages = [];
    for (var msg in historyRaw) {
      final role = msg['role'] as String;
      final content = msg['content'] as String;
      
      // We skip system messages in the UI
      if (role == 'system') continue;
      
      historyMessages.add(ChatMessage(
        id: _uuid.v4(),
        text: content,
        isUser: role == 'user',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)), // Mock timestamp
      ));
    }
    
    if (historyMessages.isNotEmpty) {
      state = historyMessages;
      _saveSession();
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

    // Synchronously unlock audio context on Safari right when the user interacts
    _aiService.unlockAudioContext();

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
      final result = await _aiService.getChatResponse(messageHistory, phone: phone, name: name, sessionId: _currentSessionId);
      final responseText = result.text;
      // The backend echoes back which thread it actually saved this turn
      // into — keep local state in sync so the NEXT message in this same
      // conversation keeps landing in the same thread instead of the
      // backend falling back to "most recent session" every time.
      if (result.sessionId != null && result.sessionId!.isNotEmpty) {
        _currentSessionId = result.sessionId!;
      }

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

}

/// Every saved chat thread for the signed-in user, fetched from the
/// backend's chat_sessions table — backs the real History screen (which
/// used to render hardcoded fake thread titles that never touched the
/// server). autoDispose since the History screen is the only consumer and
/// it should refetch fresh each time it's opened rather than go stale.
final chatSessionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final authState = ref.watch(authProvider);
  String phone = '+919876543210';
  String name = 'Judge';
  if (authState is AuthAuthenticated) {
    phone = authState.user.email.replaceAll('@astra.dev', '');
    name = authState.user.name;
  }
  return DemoAIService().fetchChatSessions(phone: phone, name: name);
});
