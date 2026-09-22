import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:convert';
import 'audio_unlock.dart';

class DemoAIService {
  static const String elevenLabsVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Rachel voice

  // Set at build/run time via `--dart-define=API_BASE_URL=...`. No fallback
  // is hardcoded here — an unset value fails fast instead of silently
  // pointing at a URL baked into source.
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get _baseUrl {
    if (_envBaseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Pass it via '
        '--dart-define=API_BASE_URL=<url> when running or building.',
      );
    }
    return _envBaseUrl;
  }

  static final DemoAIService _instance = DemoAIService._internal();
  factory DemoAIService() => _instance;
  DemoAIService._internal();

  final Dio _dio = Dio();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? _cachedJwtToken;

  // Same mocked-OTP dance every one of these calls used to duplicate
  // inline (send OTP, verify with the fixed dev code, cache the JWT for
  // TTS). Pulled out once so the session-list/session-messages calls added
  // for real chat history don't triple it again.
  Future<String> _authenticate({required String phone, required String name, List<Map<String, dynamic>>? banks}) async {
    final baseUrl = _baseUrl;
    await _dio.post(
      '$baseUrl/api/auth/otp/send',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {'phone_number': phone},
    );
    final authResponse = await _dio.post(
      '$baseUrl/api/auth/otp/verify',
      options: Options(headers: {'Content-Type': 'application/json'}),
      data: {
        'astra_user_id': phone,
        'phone_number': phone,
        'otp': '123456',
        'name': name,
        if (banks != null) 'banks': banks,
      },
    );
    final jwtToken = authResponse.data['token'] as String;
    _cachedJwtToken = jwtToken; // Cache the token for TTS requests
    return jwtToken;
  }

  /// Returns the response text and, when the backend resolved/created a
  /// session for this turn, that session's ID via the X-Chat-Session-Id
  /// response header — the caller (ChatNotifier) needs this so every
  /// subsequent message in the thread keeps saving to the same session
  /// instead of the backend falling back to "most recent session" each time.
  Future<({String text, String? sessionId})> getChatResponse(
    List<Map<String, String>> messageHistory, {
    bool isNavPill = false,
    required String phone,
    required String name,
    String? sessionId,
  }) async {
    final messages = [...messageHistory];

    try {
      final baseUrl = _baseUrl;
      final jwtToken = await _authenticate(phone: phone, name: name);

      final response = await _dio.post(
        '$baseUrl/api/chat',
        options: Options(
          headers: {
            'Authorization': 'Bearer $jwtToken',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'messages': messages,
          'is_nav_pill': isNavPill,
          if (sessionId != null) 'session_id': sessionId,
        },
      );

      final returnedSessionId = response.headers.value('x-chat-session-id');
      if (response.statusCode == 200) {
        return (text: response.data['choices'][0]['message']['content'] as String, sessionId: returnedSessionId);
      }
      return (text: 'Sorry, I encountered an error. Please try again.', sessionId: returnedSessionId);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || 
          e.type == DioExceptionType.sendTimeout || 
          e.type == DioExceptionType.receiveTimeout || 
          e.type == DioExceptionType.connectionError) {
        throw Exception("It looks like you're offline. Please check your internet connection.");
      }
      
      if (e.response?.statusCode == 429) {
        throw Exception("You are sending messages too fast! Please wait a moment.");
      }
      
      throw Exception("The server is experiencing issues. Please try again later.");
    } catch (e) {
      throw Exception("An unexpected error occurred.");
    }
  }

  Future<List<Map<String, dynamic>>> fetchChatHistory({required String phone, required String name, required List<Map<String, dynamic>> banks}) async {
    try {
      final baseUrl = _baseUrl;
      final jwtToken = await _authenticate(phone: phone, name: name, banks: banks);

      final historyResponse = await _dio.get(
        '$baseUrl/api/chat/history',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      final messages = historyResponse.data['messages'] as List<dynamic>;
      return messages.map((m) => m as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  /// Every saved chat thread for this user, newest first — backs the real
  /// History screen (previously hardcoded mock titles that never touched
  /// the backend).
  Future<List<Map<String, dynamic>>> fetchChatSessions({required String phone, required String name}) async {
    try {
      final baseUrl = _baseUrl;
      final jwtToken = await _authenticate(phone: phone, name: name);

      final response = await _dio.get(
        '$baseUrl/api/chat/sessions',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      final sessions = response.data['sessions'] as List<dynamic>? ?? [];
      return sessions.map((s) => s as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  /// Full message history for one specific thread — loaded when the user
  /// taps into a past thread from the History screen.
  Future<List<Map<String, dynamic>>?> fetchSessionMessages({
    required String phone,
    required String name,
    required String sessionId,
  }) async {
    try {
      final baseUrl = _baseUrl;
      final jwtToken = await _authenticate(phone: phone, name: name);

      final response = await _dio.get(
        '$baseUrl/api/chat/sessions/$sessionId',
        options: Options(headers: {'Authorization': 'Bearer $jwtToken'}),
      );

      final messages = response.data['messages'] as List<dynamic>? ?? [];
      return messages.map((m) => m as Map<String, dynamic>).toList();
    } catch (e) {
      return null;
    }
  }

  void unlockAudioContext() {
    unlockWebAudio();
  }

  int _speechId = 0;

  void stopSpeaking() {
    _speechId++; // Invalidate any pending network requests for TTS
    try {
      audioPlayer.stop();
    } catch (e) {
      print('Ignored audio stop error: $e');
    }
  }

  Future<void> speak(String text) async {
    if (_cachedJwtToken == null) {
      print('Skipping TTS: No JWT token available. Must authenticate first.');
      return;
    }

    final currentSpeechId = ++_speechId;
    
    try {
      final baseUrl = _baseUrl;
      final url = '$baseUrl/api/tts';
      
      // Sarvam TTS API has a strict 500 character limit.
      // We truncate the text to ~490 characters safely at a word boundary.
      String safeText = text;
      if (safeText.length > 490) {
        int lastSpace = safeText.substring(0, 490).lastIndexOf(' ');
        safeText = lastSpace > 0 ? safeText.substring(0, lastSpace) : safeText.substring(0, 490);
      }
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_cachedJwtToken',
          },
        ),
        data: {
          'text': safeText,
        },
      );

      // If a new speech request was made or stop was called, abort playback
      if (_speechId != currentSpeechId) return;

      final audioBase64 = response.data['audios'][0] as String;
      final source = AudioSource.uri(Uri.parse('data:audio/wav;base64,$audioBase64'));
      
      // Double check before playing
      if (_speechId != currentSpeechId) return;
      
      await audioPlayer.setAudioSource(source);
      
      // Final check just in case setAudioSource yielded execution
      if (_speechId != currentSpeechId) return;
      
      audioPlayer.play(); // Do not await so we can show text immediately as it starts playing
    } catch (e) {
      print('Sarvam Error: $e');
    }
  }
}
