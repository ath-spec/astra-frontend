import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DemoAIService {
  static const String elevenLabsVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Rachel voice
  
  static final DemoAIService _instance = DemoAIService._internal();
  factory DemoAIService() => _instance;
  DemoAIService._internal();

  final Dio _dio = Dio();
  final AudioPlayer audioPlayer = AudioPlayer();
  
  String? _cachedJwtToken;
  
  Future<String> getChatResponse(List<Map<String, String>> messageHistory, {bool isNavPill = false, required String phone, required String name}) async {
    final messages = [...messageHistory];

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      
      // 1. Authenticate via Mocked OTP Flow
      await _dio.post(
        '$baseUrl/api/auth/otp/send',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'phone_number': phone},
      );

      final authResponse = await _dio.post(
        '$baseUrl/api/auth/otp/verify',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'astra_user_id': phone, 
          'phone_number': phone,
          'otp': '123456',
          'name': name,
        },
      );

      final jwtToken = authResponse.data['token'];
      _cachedJwtToken = jwtToken; // Cache the token for TTS requests

      // 2. Call the chat endpoint securely with the JWT
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
        },
      );
      
      if (response.statusCode == 200) {
        return response.data['choices'][0]['message']['content'];
      }
      return 'Sorry, I encountered an error. Please try again.';
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
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      
      // Authenticate via Mocked OTP Flow
      await _dio.post(
        '$baseUrl/api/auth/otp/send',
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {'phone_number': phone},
      );

      final authResponse = await _dio.post(
        '$baseUrl/api/auth/otp/verify',
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
        data: {
          'astra_user_id': phone, 
          'phone_number': phone, 
          'otp': '123456', 
          'name': name, 
          'banks': banks
        },
      );
      final jwtToken = authResponse.data['token'];
      _cachedJwtToken = jwtToken; // Cache the token for TTS requests

      // Get History
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

  int _speechId = 0;

  void stopSpeaking() {
    _speechId++; // Invalidate any pending network requests for TTS
    audioPlayer.stop();
  }

  Future<void> speak(String text) async {
    if (_cachedJwtToken == null) {
      print('Skipping TTS: No JWT token available. Must authenticate first.');
      return;
    }

    final currentSpeechId = ++_speechId;
    
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      final url = '$baseUrl/api/tts';
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_cachedJwtToken',
          },
        ),
        data: {
          'text': text,
        },
      );

      // If a new speech request was made or stop was called, abort playback
      if (_speechId != currentSpeechId) return;

      final audioBase64 = response.data['audios'][0] as String;
      final audioData = base64Decode(audioBase64);
      final source = MyAudioSource(audioData);
      
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

class MyAudioSource extends StreamAudioSource {
  final List<int> _bytes;
  MyAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
