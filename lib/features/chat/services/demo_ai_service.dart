import 'package:dio/dio.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DemoAIService {
  String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? 'YOUR_GROQ_API_KEY';
  String get elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? 'YOUR_ELEVENLABS_API_KEY';
  static const String elevenLabsVoiceId = '21m00Tcm4TlvDq8ikWAM'; // Rachel voice
  
  final Dio _dio = Dio();
  final AudioPlayer audioPlayer = AudioPlayer();
  
  // Custom prompt from the user about investing and portfolio analysis
  String get systemPrompt => dotenv.env['AI_SYSTEM_PROMPT'] ?? 'You are a helpful assistant.';

  Future<String> getChatResponse(List<Map<String, String>> messageHistory, {String? systemPromptOverride}) async {
    final combinedPrompt = systemPromptOverride != null 
        ? '$systemPrompt\n\n$systemPromptOverride'
        : systemPrompt;
        
    final messages = [
      {'role': 'system', 'content': combinedPrompt},
      ...messageHistory,
    ];

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
      final appAuthToken = dotenv.env['APP_AUTH_TOKEN'] ?? '';
      
      // 1. Fetch JWT Token
      final authResponse = await _dio.post(
        '$baseUrl/api/auth/token',
        options: Options(
          headers: {
            'X-Astra-Auth': appAuthToken,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'astra_user_id': 'judge-1234',
          'phone_number': '+919876543210',
        },
      );

      final jwtToken = authResponse.data['token'];

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

  String get sarvamApiKey => dotenv.env['SARVAM_API_KEY'] ?? 'YOUR_SARVAM_API_KEY';

  int _speechId = 0;

  void stopSpeaking() {
    _speechId++; // Invalidate any pending network requests for TTS
    audioPlayer.stop();
  }

  Future<void> speak(String text) async {
    if (sarvamApiKey == 'YOUR_SARVAM_API_KEY') {
      print('Skipping TTS, no API key');
      return;
    }
    
    final currentSpeechId = ++_speechId;
    
    try {
      final url = 'https://api.sarvam.ai/text-to-speech';
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'api-subscription-key': sarvamApiKey,
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'inputs': [text],
          'target_language_code': 'en-IN',
          'speaker': 'shubh',
          'model': 'bulbul:v3'
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
