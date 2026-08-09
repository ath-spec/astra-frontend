// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void unlockWebAudio() {
  try {
    // Create a raw HTML audio element and play a tiny 1-byte silent data URI.
    // By triggering this synchronously during a button click (user gesture),
    // we bypass Safari's strict Autoplay block and fully unlock the Web Audio context.
    final audio = html.AudioElement();
    audio.src = 'data:audio/mpeg;base64,//NExAAAAANIAAAAAExBTUUzLjEwMKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq';
    audio.play().catchError((e) {
      // Ignored: Safari might throw if the source is considered too short, but the context is still unlocked
    });
  } catch (e) {
    print('Web Audio unlock error: $e');
  }
}
