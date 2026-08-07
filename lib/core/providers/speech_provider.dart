import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechState {
  final bool isListening;
  final bool isInitialized;
  final String recognizedWords;
  final bool hasError;

  const SpeechState({
    this.isListening = false,
    this.isInitialized = false,
    this.recognizedWords = '',
    this.hasError = false,
  });

  SpeechState copyWith({
    bool? isListening,
    bool? isInitialized,
    String? recognizedWords,
    bool? hasError,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      isInitialized: isInitialized ?? this.isInitialized,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      hasError: hasError ?? this.hasError,
    );
  }
}

class SpeechNotifier extends StateNotifier<SpeechState> {
  SpeechNotifier() : super(const SpeechState());

  final SpeechToText _speechToText = SpeechToText();
  Function(String)? _onResultCallback;

  Future<bool> initialize() async {
    if (state.isInitialized) return true;

    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    if (status.isGranted) {
      final initialized = await _speechToText.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            stopListening();
          }
        },
        onError: (val) {
          state = state.copyWith(isListening: false, hasError: true);
        },
      );
      state = state.copyWith(isInitialized: initialized);
      return initialized;
    }
    return false;
  }

  Future<void> startListening({Function(String)? onResultCallback}) async {
    _onResultCallback = onResultCallback;
    final initialized = await initialize();
    if (!initialized) return;

    state = state.copyWith(isListening: true, recognizedWords: '', hasError: false);
    
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 5),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.dictation,
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    state = state.copyWith(recognizedWords: result.recognizedWords);
    if (_onResultCallback != null) {
      _onResultCallback!(result.recognizedWords);
    }
  }

  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
    state = state.copyWith(isListening: false);
  }
  
  Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
    state = state.copyWith(isListening: false, recognizedWords: '');
  }
}

final speechProvider = StateNotifierProvider<SpeechNotifier, SpeechState>((ref) {
  return SpeechNotifier();
});
