// Voice input for the app chat and nav-bar quick-chat mic. Mirrors
// officergram's realtime STT (lib/core/providers/speech_provider.dart there):
// stream raw 16kHz PCM16 audio to the backend over a WebSocket, which proxies
// it to Sarvam's realtime speech-to-text and streams back partial/final
// transcript events. Sarvam auto-detects the spoken language and transcribes
// in its own native script — nothing here forces a fixed locale (the old
// on-device recognizer this replaces hardcoded 'en_IN', mis-recognizing
// non-English speech as English).
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../network/api.dart';

class SpeechState {
  final bool isListening;
  final bool isProcessing; // stream closing, waiting for the final transcript
  final String recognizedWords;
  final bool hasError;
  final String errorMessage;
  // True once listening has run for a while with no transcript event at
  // all (partial or final) — distinct from hasError, which is a fatal
  // connection failure that stops listening. isStruggling keeps the mic
  // open (the user might just be in a noisy room) but gives the UI
  // something to show instead of silently doing nothing for 20+ seconds.
  final bool isStruggling;

  const SpeechState({
    this.isListening = false,
    this.isProcessing = false,
    this.recognizedWords = '',
    this.hasError = false,
    this.errorMessage = '',
    this.isStruggling = false,
  });

  SpeechState copyWith({
    bool? isListening,
    bool? isProcessing,
    String? recognizedWords,
    bool? hasError,
    String? errorMessage,
    bool? isStruggling,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      isProcessing: isProcessing ?? this.isProcessing,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isStruggling: isStruggling ?? this.isStruggling,
    );
  }
}

class SpeechNotifier extends StateNotifier<SpeechState> {
  SpeechNotifier() : super(const SpeechState());

  final AudioRecorder _record = AudioRecorder();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  Function(String)? _onResultCallback;
  WebSocketChannel? _channel;
  StreamSubscription? _audioSub;
  StreamSubscription? _wsSub;
  // Sarvam emits a transcript.final every time the speaker pauses between
  // phrases (a segment boundary), not just when they're done talking — the
  // stream keeps running and starts transcribing the next segment right
  // after. _finalizedText accumulates each finished segment across the
  // whole listening session so pausing mid-thought doesn't wipe out
  // everything said before the pause.
  String _finalizedText = '';

  // Sarvam's streaming partials frequently revise their own trailing words
  // as more audio context arrives — normal for realtime ASR, but applying
  // every single revision straight to the state (and from there into a live
  // TextEditingController) made the visible text flicker/rewrite itself
  // several times a second. Partial updates are debounced so only the
  // settled value after a short pause gets applied; final segments (a real
  // phrase boundary) still apply immediately since they won't be revised.
  Timer? _partialDebounce;
  static const _partialDebounceDelay = Duration(milliseconds: 220);

  // Fires once if listening runs for a while with no transcript event at
  // all — see SpeechState.isStruggling.
  Timer? _noSpeechTimer;
  static const _noSpeechTimeout = Duration(seconds: 7);

  // startListening does several awaits (permission check, secure-storage
  // read, socket connect, recorder start) before the mic/socket are fully
  // wired up. If stopListening/cancelListening/a second startListening runs
  // during one of those gaps, the two calls interleave and the slower one
  // can silently overwrite the other's cleanup — leaving a "zombie" mic
  // stream running after the user thinks they stopped it. Every mutating
  // call bumps this counter and captures its own value up front; each
  // await-resume point in startListening re-checks it and self-aborts
  // (tearing down whatever it just opened) if a newer call has started.
  int _generation = 0;

  Future<bool> initialize() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        status = await Permission.microphone.request();
      }
      if (status.isPermanentlyDenied) {
        state = state.copyWith(
          hasError: true,
          errorMessage: 'Microphone permission is permanently denied. Please enable it in Settings.',
        );
        await openAppSettings();
        return false;
      }
    } catch (_) {
      // Permission handler is a no-op on some platforms; fall through to
      // record's own hasPermission() as the real gate.
    }
    return _record.hasPermission();
  }

  Future<void> startListening({Function(String)? onResultCallback}) async {
    final gen = ++_generation;
    _onResultCallback = onResultCallback;
    final initialized = await initialize();
    if (!initialized || gen != _generation) return;

    _finalizedText = '';
    state = state.copyWith(isListening: true, isProcessing: false, recognizedWords: '', hasError: false, errorMessage: '', isStruggling: false);

    WebSocketChannel? channel;
    StreamSubscription? wsSub;
    try {
      final baseUrl = dioApiClient.dio.options.baseUrl;
      final wsUrl = baseUrl.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
      final token = await _secureStorage.read(key: 'auth_token');
      if (gen != _generation) return; // a stop/cancel/newer start won while we were reading the token

      final tokenQuery = (token != null && token.isNotEmpty) ? '&token=$token' : '';
      final uri = Uri.parse('$wsUrl/api/chat/stt/stream?lang=auto$tokenQuery');
      final headers = (token != null && token.isNotEmpty) ? {'Authorization': 'Bearer $token'} : null;

      channel = IOWebSocketChannel.connect(uri, headers: headers);
      wsSub = channel.stream.listen(
        (message) {
          if (gen != _generation) return; // frame from a superseded session
          try {
            if (message is String) {
              final data = json.decode(message);
              if (data['event'] == 'transcript.partial' || data['event'] == 'transcript.final') {
                // Any transcript event at all means Sarvam is hearing us —
                // cancel the "having trouble hearing you" timer/flag.
                _noSpeechTimer?.cancel();
                _noSpeechTimer = null;
                if (state.isStruggling) {
                  state = state.copyWith(isStruggling: false, errorMessage: '');
                }

                final segment = data['text'] as String?;
                final isFinal = data['event'] == 'transcript.final';
                // Combine everything already finalized this session with
                // either the just-finalized segment or the in-progress
                // partial, so the exposed text always reads as one
                // continuous, growing transcript rather than resetting to
                // just the latest segment on every pause.
                String combined = _finalizedText;
                if (segment != null && segment.trim().isNotEmpty) {
                  combined = _finalizedText.isEmpty ? segment : '$_finalizedText $segment';
                }
                if (isFinal) {
                  _finalizedText = combined;
                }
                if (combined.trim().isEmpty) {
                  // nothing to apply yet
                } else if (isFinal) {
                  // Final segments are settled (won't be revised) — apply
                  // immediately and drop any pending partial debounce so it
                  // can't overwrite this with a stale, older partial.
                  _partialDebounce?.cancel();
                  _partialDebounce = null;
                  _applyTranscript(gen, combined);
                } else {
                  // Partial: Sarvam commonly revises the last word or two as
                  // more audio context arrives, so wait for a short pause in
                  // updates before pushing this into the visible text —
                  // avoids the field rewriting itself several times a second.
                  _partialDebounce?.cancel();
                  _partialDebounce = Timer(_partialDebounceDelay, () {
                    _applyTranscript(gen, combined);
                  });
                }
                // Do NOT stop on a final — Sarvam finalizes each segment as
                // the speaker pauses between phrases; the session should
                // keep listening for more speech until the user explicitly
                // stops (or the socket itself closes after a longer silence).
              }
            }
          } catch (_) {
            // Malformed/unexpected frame — ignore and keep listening.
          }
        },
        onError: (_) async {
          if (gen != _generation) return;
          _partialDebounce?.cancel();
          _partialDebounce = null;
          _noSpeechTimer?.cancel();
          _noSpeechTimer = null;
          await _cleanupRecording();
          state = state.copyWith(
            isListening: false,
            isProcessing: false,
            hasError: true,
            isStruggling: false,
            errorMessage: 'Voice stream connection unavailable. Please type your query.',
          );
        },
        onDone: () {
          if (gen == _generation && state.isListening) {
            state = state.copyWith(isListening: false);
          }
        },
        cancelOnError: true,
      );

      final stream = await _record.startStream(
        const RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1),
      );
      if (gen != _generation) {
        // A stop/cancel/newer start won while the recorder was spinning up —
        // this session lost, so tear down what it just opened and leave the
        // fields (and the recorder, already claimed by the newer session)
        // alone rather than clobbering them.
        await wsSub.cancel();
        await channel.sink.close();
        return;
      }

      _channel = channel;
      _wsSub = wsSub;
      _audioSub = stream.listen((data) {
        final payload = jsonEncode({'event': 'audio_input', 'audio': base64Encode(data)});
        try {
          _channel?.sink.add(payload);
        } catch (_) {}
      });

      // If nothing at all comes back from Sarvam for a while (e.g. it can't
      // pick the user's voice out of background noise), say so instead of
      // leaving the mic open with zero feedback — previously this state was
      // never surfaced in the UI at all.
      _noSpeechTimer?.cancel();
      _noSpeechTimer = Timer(_noSpeechTimeout, () {
        if (gen != _generation || !state.isListening) return;
        if (state.recognizedWords.trim().isEmpty) {
          state = state.copyWith(
            isStruggling: true,
            errorMessage: "Having trouble hearing you — try speaking louder or moving somewhere quieter.",
          );
        }
      });
    } catch (e) {
      await wsSub?.cancel();
      await channel?.sink.close();
      if (gen != _generation) return;
      await _cleanupRecording();
      state = state.copyWith(isListening: false, hasError: true, errorMessage: 'Voice input service unavailable.');
    }
  }

  void _applyTranscript(int gen, String combined) {
    if (gen != _generation) return;
    state = state.copyWith(recognizedWords: combined);
    _onResultCallback?.call(combined);
  }

  Future<void> _cleanupRecording() async {
    try {
      await _audioSub?.cancel();
      _audioSub = null;
      if (await _record.isRecording()) {
        await _record.stop();
      }
    } catch (_) {}
  }

  Future<void> stopListening() async {
    if (!state.isListening) return;
    _generation++; // supersede any startListening still mid-flight
    _partialDebounce?.cancel();
    _partialDebounce = null;
    _noSpeechTimer?.cancel();
    _noSpeechTimer = null;
    state = state.copyWith(isListening: false, isProcessing: true, isStruggling: false);
    try {
      await _audioSub?.cancel();
      _audioSub = null;
      if (await _record.isRecording()) {
        await _record.stop();
      }
      await _wsSub?.cancel();
      _wsSub = null;
      await _channel?.sink.close();
      _channel = null;
      state = state.copyWith(isProcessing: false);
    } catch (_) {
      state = state.copyWith(isProcessing: false, hasError: true);
    }
  }

  Future<void> cancelListening() async {
    _generation++; // supersede any startListening still mid-flight
    _partialDebounce?.cancel();
    _partialDebounce = null;
    _noSpeechTimer?.cancel();
    _noSpeechTimer = null;
    try {
      await _audioSub?.cancel();
      _audioSub = null;
      if (await _record.isRecording()) {
        await _record.stop();
      }
      await _wsSub?.cancel();
      _wsSub = null;
      await _channel?.sink.close();
      _channel = null;
    } catch (_) {}
    _onResultCallback = null;
    _finalizedText = '';
    state = state.copyWith(isListening: false, isProcessing: false, recognizedWords: '', isStruggling: false);
  }
}

final speechProvider = StateNotifierProvider<SpeechNotifier, SpeechState>((ref) {
  return SpeechNotifier();
});
