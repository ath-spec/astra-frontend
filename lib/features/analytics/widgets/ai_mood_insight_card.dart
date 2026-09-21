// ============================================================
// FILE: lib/features/analytics/widgets/ai_mood_insight_card.dart
// The AI insight card at the top of the Analytics screen: a
// hand-painted "blob face" avatar (geometry + micro-animations
// ported from zeyro_new_ui's _KawaiFacePainter, re-skinned to
// astra's mood palette) next to a typed, shimmering narrative —
// reusing the same TypewriterText + AnimatedGradientShimmer pair
// already used by the Discipline/Allocation insight cards in
// portfolio_analysis.
//
// All 3 emotional states from zeyro are captured 1:1 (happy / sad /
// disappointed — labelled here as happy / neutral / concerned) with
// their full micro-animation sets:
//   happy       -> occasional wink, double brow-raise, grin, blush+sparkle
//   neutral     -> looping tears, whimper (mouth quiver), sniffle dip
//   concerned   -> anger flash (brow furrow), head-shake
// on top of the shared idle look-around, blink, bob and morph-in.
// ============================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/widgets/typewriter_text.dart';
import '../../../core/widgets/animated_gradient_text.dart';
import '../models/analytics_models.dart';

class AiMoodInsightCard extends StatelessWidget {
  final AiMood mood;
  final String text;
  final bool isLoading;

  const AiMoodInsightCard({
    super.key,
    required this.mood,
    required this.text,
    this.isLoading = false,
  });

  String _cleanText(String raw) {
    return raw
        .replaceAll('**', '')
        .replaceAll('__', '')
        .replaceAll('—', ' - ')
        .replaceAll('–', ' - ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final cleaned = _cleanText(text);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: isLoading
                ? const _InsightSkeletonLines()
                : AnimatedGradientShimmer(
                    child: TypewriterText(
                      key: ValueKey(cleaned),
                      text: cleaned,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 11.0,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 14),
        _MoodAvatar(mood: mood, isThinking: isLoading),
      ],
    );
  }
}

/// Blob-face mood avatar with the full micro-animation set ported
/// from zeyro_new_ui's _AiEmotionInsightState — idle look-around,
/// blink, bob/morph, plus per-mood secondary actions.
class _MoodAvatar extends StatefulWidget {
  final AiMood mood;
  final bool isThinking;

  const _MoodAvatar({required this.mood, required this.isThinking});

  @override
  State<_MoodAvatar> createState() => _MoodAvatarState();
}

class _MoodAvatarState extends State<_MoodAvatar> with TickerProviderStateMixin {
  // Core.
  late final AnimationController _morphController;
  late final AnimationController _bobController;
  late final AnimationController _blinkController;
  late final List<double> _blobNoise;
  final _rng = math.Random();

  // 2-D gaze.
  Offset _gazeFrom = Offset.zero;
  Offset _gazeTo = Offset.zero;
  late final AnimationController _gazeController;
  int _lookGeneration = 0;

  // Happy.
  late final AnimationController _winkController;
  bool _winkLeftEye = true;
  late final AnimationController _browRaiseController;
  late final AnimationController _grinController;
  late final AnimationController _blushController;

  // Neutral (sad-shape).
  late final AnimationController _tearController;
  late final AnimationController _whimperController;
  late final AnimationController _sniffleController;

  // Concerned (disappointed-shape).
  late final AnimationController _angerFlashController;
  late final AnimationController _headShakeController;

  Offset get _currentGaze => Offset.lerp(_gazeFrom, _gazeTo, _gazeController.value) ?? Offset.zero;

  @override
  void initState() {
    super.initState();
    _blobNoise = List.generate(12, (_) => _rng.nextDouble());

    _morphController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))..forward();
    _bobController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))..repeat(reverse: true);
    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _gazeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _winkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 240));
    _browRaiseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _grinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _blushController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _tearController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
    _whimperController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _sniffleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _angerFlashController = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _headShakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _scheduleNextBlink();
    _startLookAround();

    switch (widget.mood) {
      case AiMood.happy:
        Future.delayed(const Duration(milliseconds: 3500), _scheduleWink);
        Future.delayed(const Duration(milliseconds: 4500), _scheduleBrowRaise);
        Future.delayed(const Duration(milliseconds: 3000), _scheduleGrin);
        Future.delayed(const Duration(milliseconds: 5500), _scheduleBlush);
        break;
      case AiMood.neutral:
        Future.delayed(const Duration(milliseconds: 1400), _loopTear);
        Future.delayed(const Duration(milliseconds: 2200), _scheduleWhimper);
        Future.delayed(const Duration(milliseconds: 3600), _scheduleSniffle);
        break;
      case AiMood.concerned:
        Future.delayed(const Duration(milliseconds: 2600), _scheduleAngerFlash);
        Future.delayed(const Duration(milliseconds: 4400), _scheduleHeadShake);
        break;
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _bobController.dispose();
    _blinkController.dispose();
    _gazeController.dispose();
    _winkController.dispose();
    _browRaiseController.dispose();
    _grinController.dispose();
    _blushController.dispose();
    _tearController.dispose();
    _whimperController.dispose();
    _sniffleController.dispose();
    _angerFlashController.dispose();
    _headShakeController.dispose();
    super.dispose();
  }

  void _snapGazeTo(Offset target, {int ms = 400}) {
    if (!mounted) return;
    _gazeFrom = _currentGaze;
    _gazeTo = target;
    _gazeController.duration = Duration(milliseconds: ms);
    _gazeController.forward(from: 0);
  }

  List<Offset> get _idlePool => const [
        Offset(0, 0),
        Offset(-0.7, -0.3),
        Offset(0.6, -0.25),
        Offset(-0.5, 0.3),
        Offset(0.5, 0.3),
        Offset(0, -0.5),
      ];

  void _startLookAround() {
    final gen = ++_lookGeneration;
    _doNextLook(gen);
  }

  void _doNextLook(int gen) {
    if (!mounted || gen != _lookGeneration) return;
    final target = _idlePool[_rng.nextInt(_idlePool.length)];
    _snapGazeTo(target, ms: 380);
    Future.delayed(Duration(milliseconds: 380 + 900 + _rng.nextInt(1000)), () => _doNextLook(gen));
  }

  void _scheduleNextBlink() {
    Future.delayed(Duration(milliseconds: 2000 + _rng.nextInt(3000)), () {
      if (!mounted) return;
      _blinkController.forward().then((_) {
        if (!mounted) return;
        _blinkController.reverse().then((_) => _scheduleNextBlink());
      });
    });
  }

  // ── Happy: wink ─────────────────────────────────────────────
  void _scheduleWink() {
    if (!mounted || widget.mood != AiMood.happy) return;
    Future.delayed(Duration(milliseconds: 4000 + _rng.nextInt(5000)), () {
      if (!mounted || widget.mood != AiMood.happy) return;
      setState(() => _winkLeftEye = _rng.nextBool());
      _winkController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 160), () {
          if (!mounted) return;
          _winkController.reverse().then((_) {
            if (mounted) _scheduleWink();
          });
        });
      });
    });
  }

  // ── Happy: double brow raise ────────────────────────────────
  void _scheduleBrowRaise() {
    if (!mounted || widget.mood != AiMood.happy) return;
    Future.delayed(Duration(milliseconds: 7000 + _rng.nextInt(6000)), () {
      if (!mounted || widget.mood != AiMood.happy) return;
      _browRaiseController.forward(from: 0).then((_) {
        _browRaiseController.reverse().then((_) {
          Future.delayed(const Duration(milliseconds: 220), () {
            if (!mounted) return;
            _browRaiseController.forward(from: 0).then((_) {
              _browRaiseController.reverse().then((_) {
                if (mounted) _scheduleBrowRaise();
              });
            });
          });
        });
      });
    });
  }

  // ── Happy: grin ──────────────────────────────────────────────
  void _scheduleGrin() {
    if (!mounted || widget.mood != AiMood.happy) return;
    Future.delayed(Duration(milliseconds: 6000 + _rng.nextInt(6000)), () {
      if (!mounted || widget.mood != AiMood.happy) return;
      _grinController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _grinController.reverse().then((_) {
            if (mounted) _scheduleGrin();
          });
        });
      });
    });
  }

  // ── Happy: blush + eye sparkle ──────────────────────────────
  void _scheduleBlush() {
    if (!mounted || widget.mood != AiMood.happy) return;
    Future.delayed(Duration(milliseconds: 8000 + _rng.nextInt(9000)), () {
      if (!mounted || widget.mood != AiMood.happy) return;
      _blushController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          _blushController.reverse().then((_) {
            if (mounted) _scheduleBlush();
          });
        });
      });
    });
  }

  // ── Neutral: looping tears ──────────────────────────────────
  void _loopTear() {
    if (!mounted || widget.mood != AiMood.neutral) return;
    _tearController.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 1100), () {
        if (mounted) _loopTear();
      });
    });
  }

  // ── Neutral: whimper (mouth quiver) ─────────────────────────
  void _scheduleWhimper() {
    if (!mounted || widget.mood != AiMood.neutral) return;
    Future.delayed(Duration(milliseconds: 4000 + _rng.nextInt(4000)), () {
      if (!mounted || widget.mood != AiMood.neutral) return;
      _whimperController.forward(from: 0).then((_) {
        _whimperController.reset();
        if (mounted) _scheduleWhimper();
      });
    });
  }

  // ── Neutral: sniffle dip ────────────────────────────────────
  void _scheduleSniffle() {
    if (!mounted || widget.mood != AiMood.neutral) return;
    Future.delayed(Duration(milliseconds: 5000 + _rng.nextInt(5000)), () {
      if (!mounted || widget.mood != AiMood.neutral) return;
      _sniffleController.forward(from: 0).then((_) {
        _sniffleController.reset();
        if (mounted) _scheduleSniffle();
      });
    });
  }

  // ── Concerned: anger flash ──────────────────────────────────
  void _scheduleAngerFlash() {
    if (!mounted || widget.mood != AiMood.concerned) return;
    Future.delayed(Duration(milliseconds: 9000 + _rng.nextInt(10000)), () {
      if (!mounted || widget.mood != AiMood.concerned) return;
      _angerFlashController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!mounted) return;
          _angerFlashController.reverse().then((_) {
            if (mounted) _scheduleAngerFlash();
          });
        });
      });
    });
  }

  // ── Concerned: head-shake ───────────────────────────────────
  void _scheduleHeadShake() {
    if (!mounted || widget.mood != AiMood.concerned) return;
    Future.delayed(Duration(milliseconds: 7000 + _rng.nextInt(8000)), () {
      if (!mounted || widget.mood != AiMood.concerned) return;
      _headShakeController.forward(from: 0).then((_) {
        _headShakeController.reset();
        if (mounted) _scheduleHeadShake();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _morphController,
        _bobController,
        _blinkController,
        _gazeController,
        _winkController,
        _browRaiseController,
        _grinController,
        _blushController,
        _tearController,
        _whimperController,
        _sniffleController,
        _angerFlashController,
        _headShakeController,
      ]),
      builder: (context, child) {
        final scale = _morphController.value;
        final bob = math.sin(_bobController.value * math.pi) * 2.4;
        final sniffleY = math.sin(_sniffleController.value * math.pi) * 3.0;
        final shakeX = math.sin(_headShakeController.value * math.pi * 5) * 3.5;
        final gaze = _currentGaze;

        return Transform.translate(
          offset: Offset(shakeX, -(bob + sniffleY)),
          child: Transform.scale(
            scale: 0.9 + 0.1 * scale,
            child: Opacity(
              opacity: scale.clamp(0.0, 1.0),
              child: SizedBox(
                width: 58,
                height: 58,
                child: CustomPaint(
                  painter: _BlobFacePainter(
                    morphT: scale,
                    blinkT: _blinkController.value,
                    mood: widget.mood,
                    gazeOffset: Offset(gaze.dx * 2.2, gaze.dy * 1.6),
                    isThinking: widget.isThinking,
                    blobNoise: _blobNoise,
                    winkT: _winkController.value,
                    winkLeft: _winkLeftEye,
                    browRaiseT: _browRaiseController.value,
                    grinT: _grinController.value,
                    blushT: _blushController.value,
                    tearT: _tearController.value,
                    whimperT: _whimperController.value,
                    angerFlashT: _angerFlashController.value,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BlobFacePainter extends CustomPainter {
  final double morphT;
  final double blinkT;
  final AiMood mood;
  final Offset gazeOffset;
  final bool isThinking;
  final List<double> blobNoise;
  final double winkT;
  final bool winkLeft;
  final double browRaiseT;
  final double grinT;
  final double blushT;
  final double tearT;
  final double whimperT;
  final double angerFlashT;

  const _BlobFacePainter({
    required this.morphT,
    required this.blinkT,
    required this.mood,
    required this.gazeOffset,
    required this.isThinking,
    required this.blobNoise,
    required this.winkT,
    required this.winkLeft,
    required this.browRaiseT,
    required this.grinT,
    required this.blushT,
    required this.tearT,
    required this.whimperT,
    required this.angerFlashT,
  });

  static const _featureColor = Color(0xFF0F172A);
  static const _tearBlue = Color(0xFF60A5FA);
  static const _blush = Color(0xFFFDA4AF);

  // astra mood palette — happy=mint/green, neutral=azure, concerned=amber.
  static const _happyFill = Color(0xFFD1FAE5);
  static const _happyShadow = Color(0xFF6EE7B7);
  static const _neutralFill = Color(0xFFDCE9FB);
  static const _neutralShadow = Color(0xFF93C5FD);
  static const _concernedFill = Color(0xFFFEF3C7);
  static const _concernedShadow = Color(0xFFFBBF77);

  Color get _faceFill => switch (mood) {
        AiMood.happy => _happyFill,
        AiMood.neutral => _neutralFill,
        AiMood.concerned => _concernedFill,
      };
  Color get _faceShadow => switch (mood) {
        AiMood.happy => _happyShadow,
        AiMood.neutral => _neutralShadow,
        AiMood.concerned => _concernedShadow,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final faceR = size.width / 2 - 1;

    _drawBlobFace(canvas, Offset(cx, cy), faceR);
    if (morphT < 0.05) return;
    final alpha = morphT.clamp(0.0, 1.0);

    if (isThinking) {
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(Offset(cx + (i - 1) * 7.5, cy), 2.0, Paint()..color = _featureColor.withValues(alpha: alpha * 0.85));
      }
      return;
    }

    final eyeY = cy - size.height * 0.10;
    final eyeOffX = size.width * 0.175;
    _drawEyes(canvas, cx, eyeY, eyeOffX, alpha);
    _drawBrows(canvas, cx, eyeY, eyeOffX, alpha);
    _drawMouth(canvas, cx, cy, faceR, alpha);

    if (mood == AiMood.happy && blushT > 0.01) {
      _drawBlush(canvas, cx, eyeY, eyeOffX, alpha);
    }
  }

  void _drawBlobFace(Canvas canvas, Offset c, double r) {
    final path = _buildBlobPath(c, r);
    canvas.drawPath(path, Paint()..color = _faceShadow.withValues(alpha: 0.45)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(path, Paint()..color = _faceFill);
  }

  Path _buildBlobPath(Offset c, double r) {
    final d = r * 2;
    Offset p(double u, double v) => Offset(c.dx + (u - 0.5) * d, c.dy + (v - 0.5) * d);
    double n(int i) => blobNoise[i % blobNoise.length] - 0.5;

    switch (mood) {
      case AiMood.happy:
        const mag = 0.08;
        return Path()
          ..moveTo(p(0.50, 0.06).dx, p(0.50, 0.06).dy)
          ..cubicTo(p(0.80 + n(0) * mag, 0.00 + n(1) * mag).dx, p(0.80 + n(0) * mag, 0.00 + n(1) * mag).dy,
              p(1.04 + n(2) * mag, 0.20 + n(3) * mag).dx, p(1.04 + n(2) * mag, 0.20 + n(3) * mag).dy,
              p(1.00 + n(4) * mag * 0.5, 0.52).dx, p(1.00 + n(4) * mag * 0.5, 0.52).dy)
          ..cubicTo(p(0.97 + n(5) * mag, 0.78 + n(6) * mag).dx, p(0.97 + n(5) * mag, 0.78 + n(6) * mag).dy,
              p(0.76 + n(7) * mag, 0.98 + n(8) * mag).dx, p(0.76 + n(7) * mag, 0.98 + n(8) * mag).dy,
              p(0.48 + n(9) * mag * 0.4, 0.94).dx, p(0.48 + n(9) * mag * 0.4, 0.94).dy)
          ..cubicTo(p(0.16 + n(10) * mag, 0.90 + n(11) * mag).dx, p(0.16 + n(10) * mag, 0.90 + n(11) * mag).dy,
              p(-0.02 + n(0) * mag, 0.70 + n(1) * mag).dx, p(-0.02 + n(0) * mag, 0.70 + n(1) * mag).dy,
              p(0.02, 0.46 + n(2) * mag * 0.4).dx, p(0.02, 0.46 + n(2) * mag * 0.4).dy)
          ..cubicTo(p(0.04 + n(3) * mag, 0.20 + n(4) * mag).dx, p(0.04 + n(3) * mag, 0.20 + n(4) * mag).dy,
              p(0.22 + n(5) * mag, 0.02 + n(6) * mag).dx, p(0.22 + n(5) * mag, 0.02 + n(6) * mag).dy,
              p(0.50, 0.06).dx, p(0.50, 0.06).dy)
          ..close();

      case AiMood.neutral:
        const magS = 0.07;
        return Path()
          ..moveTo(p(0.50, 0.04).dx, p(0.50, 0.04).dy)
          ..cubicTo(p(0.68 + n(0) * magS, 0.01 + n(1) * magS).dx, p(0.68 + n(0) * magS, 0.01 + n(1) * magS).dy,
              p(0.92 + n(2) * magS, 0.16 + n(3) * magS).dx, p(0.92 + n(2) * magS, 0.16 + n(3) * magS).dy,
              p(0.94 + n(4) * magS * 0.4, 0.46).dx, p(0.94 + n(4) * magS * 0.4, 0.46).dy)
          ..cubicTo(p(0.96 + n(5) * magS, 0.70 + n(6) * magS).dx, p(0.96 + n(5) * magS, 0.70 + n(6) * magS).dy,
              p(0.84 + n(7) * magS, 1.00 + n(8) * magS * 0.5).dx, p(0.84 + n(7) * magS, 1.00 + n(8) * magS * 0.5).dy,
              p(0.50 + n(9) * magS * 0.3, 0.99).dx, p(0.50 + n(9) * magS * 0.3, 0.99).dy)
          ..cubicTo(p(0.14 + n(10) * magS, 0.98 + n(11) * magS * 0.5).dx, p(0.14 + n(10) * magS, 0.98 + n(11) * magS * 0.5).dy,
              p(0.02 + n(0) * magS, 0.72 + n(1) * magS).dx, p(0.02 + n(0) * magS, 0.72 + n(1) * magS).dy,
              p(0.04, 0.46 + n(2) * magS * 0.4).dx, p(0.04, 0.46 + n(2) * magS * 0.4).dy)
          ..cubicTo(p(0.06 + n(3) * magS, 0.18 + n(4) * magS).dx, p(0.06 + n(3) * magS, 0.18 + n(4) * magS).dy,
              p(0.30 + n(5) * magS, 0.01 + n(6) * magS).dx, p(0.30 + n(5) * magS, 0.01 + n(6) * magS).dy,
              p(0.50, 0.04).dx, p(0.50, 0.04).dy)
          ..close();

      case AiMood.concerned:
        const magD = 0.11;
        return Path()
          ..moveTo(p(0.50, 0.12).dx, p(0.50, 0.12).dy)
          ..cubicTo(p(0.76 + n(0) * magD, 0.05 + n(1) * magD).dx, p(0.76 + n(0) * magD, 0.05 + n(1) * magD).dy,
              p(1.00 + n(2) * magD, 0.14 + n(3) * magD).dx, p(1.00 + n(2) * magD, 0.14 + n(3) * magD).dy,
              p(0.96 + n(4) * magD * 0.4, 0.44).dx, p(0.96 + n(4) * magD * 0.4, 0.44).dy)
          ..cubicTo(p(0.93 + n(5) * magD, 0.60 + n(6) * magD).dx, p(0.93 + n(5) * magD, 0.60 + n(6) * magD).dy,
              p(0.82 + n(7) * magD, 0.88 + n(8) * magD).dx, p(0.82 + n(7) * magD, 0.88 + n(8) * magD).dy,
              p(0.54 + n(9) * magD * 0.4, 0.92).dx, p(0.54 + n(9) * magD * 0.4, 0.92).dy)
          ..cubicTo(p(0.26 + n(10) * magD, 0.96 + n(11) * magD * 0.5).dx, p(0.26 + n(10) * magD, 0.96 + n(11) * magD * 0.5).dy,
              p(0.00 + n(0) * magD, 0.80 + n(1) * magD).dx, p(0.00 + n(0) * magD, 0.80 + n(1) * magD).dy,
              p(0.04, 0.50 + n(2) * magD * 0.4).dx, p(0.04, 0.50 + n(2) * magD * 0.4).dy)
          ..cubicTo(p(0.06 + n(3) * magD, 0.28 + n(4) * magD).dx, p(0.06 + n(3) * magD, 0.28 + n(4) * magD).dy,
              p(0.24 + n(5) * magD, 0.10 + n(6) * magD).dx, p(0.24 + n(5) * magD, 0.10 + n(6) * magD).dy,
              p(0.50, 0.12).dx, p(0.50, 0.12).dy)
          ..close();
    }
  }

  // ── Eyes (with wink crescent) ────────────────────────────────
  void _drawEyes(Canvas canvas, double cx, double eyeY, double offX, double alpha) {
    final positions = [cx - offX, cx + offX];
    for (var i = 0; i < 2; i++) {
      final isLeft = i == 0;
      final ex = positions[i] + gazeOffset.dx;
      final ey = eyeY + gazeOffset.dy;

      final isWinkEye = mood == AiMood.happy && winkT > 0.01 && (isLeft == winkLeft);
      final winkFactor = isWinkEye ? (1 - winkT) : 1.0;
      final smizeFactor = (!isWinkEye && mood == AiMood.happy && winkT > 0.01) ? (1 - winkT * 0.3) : 1.0;
      final openness = (1 - blinkT) * winkFactor * smizeFactor;

      _drawDot(canvas, ex, ey, openness, alpha, isWinkEye ? winkT : 0.0);
    }

    if (mood == AiMood.neutral && tearT > 0 && morphT > 0.7) {
      _drawTears(canvas, cx - offX + gazeOffset.dx, cx + offX + gazeOffset.dx, eyeY + gazeOffset.dy, alpha);
    }
  }

  void _drawDot(Canvas canvas, double ex, double ey, double openness, double alpha, double winkProgress) {
    const dotR = 2.2;
    final color = _featureColor.withValues(alpha: alpha * 0.88);
    final clampedOpen = openness.clamp(0.0, 1.0);

    if (winkProgress > 0.45) {
      final t = ((winkProgress - 0.45) / 0.55).clamp(0.0, 1.0);
      final arcW = dotR * 1.3;
      final arcSag = -dotR * 0.7 * t;
      canvas.drawPath(
        Path()
          ..moveTo(ex - arcW, ey)
          ..quadraticBezierTo(ex, ey + arcSag, ex + arcW, ey),
        Paint()
          ..color = color
          ..strokeWidth = 1.7
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
      return;
    }

    if (clampedOpen < 0.10) {
      canvas.drawLine(
        Offset(ex - dotR, ey),
        Offset(ex + dotR, ey),
        Paint()
          ..color = color
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    final ry = dotR * clampedOpen;
    canvas.drawOval(Rect.fromCenter(center: Offset(ex, ey), width: dotR * 2, height: ry * 2), Paint()..color = color);
  }

  // ── Neutral: tears ───────────────────────────────────────────
  void _drawTears(Canvas canvas, double lx, double rx, double eyeY, double alpha) {
    const maxDrop = 16.0;
    final tearPaint = Paint()
      ..color = _tearBlue.withValues(alpha: ((1 - tearT) * 0.75 + 0.2) * alpha)
      ..style = PaintingStyle.fill;

    for (final ex in [lx, rx]) {
      final ty = eyeY + 3.0 + tearT * maxDrop;
      final ts = 1.4 + tearT * 2.0;
      canvas.drawOval(Rect.fromCenter(center: Offset(ex + 0.5, ty), width: ts, height: ts * 1.6), tearPaint);
    }
  }

  // ── Brows (happy flash / concerned furrow) ──────────────────
  void _drawBrows(Canvas canvas, double cx, double eyeY, double offX, double alpha) {
    final lx = cx - offX;
    final rx = cx + offX;
    const hw = 5.0;
    const liftBase = 8.5;

    double tiltL = 0, tiltR = 0, extraLift = 0.0;
    Color browColor;

    switch (mood) {
      case AiMood.happy:
        if (browRaiseT < 0.02) return;
        browColor = _featureColor.withValues(alpha: alpha * browRaiseT * 0.6);
        extraLift = -4.5 * browRaiseT;
        break;
      case AiMood.neutral:
        return;
      case AiMood.concerned:
        browColor = _featureColor.withValues(alpha: alpha * (0.42 + 0.30 * angerFlashT));
        tiltL = -1.8 + (-5.0 - -1.8) * angerFlashT;
        tiltR = 1.8 + (5.0 - 1.8) * angerFlashT;
        extraLift = 2.6 * angerFlashT;
        break;
    }

    final browPaint = Paint()
      ..color = browColor
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final browY = eyeY - liftBase + extraLift;
    canvas.drawLine(Offset(lx - hw, browY - tiltL), Offset(lx + hw, browY + tiltL), browPaint);
    canvas.drawLine(Offset(rx - hw, browY + tiltR), Offset(rx + hw, browY - tiltR), browPaint);
  }

  // ── Mouth (grin / whimper quiver / anger deepen) ────────────
  void _drawMouth(Canvas canvas, double cx, double cy, double faceR, double alpha) {
    final mouthY = cy + faceR * 0.30;
    final paint = Paint()
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (mood) {
      case AiMood.happy:
        final hwG = 12.0 + grinT * 4.5;
        final rise = 6.0 + grinT * 2.5;
        final arc = 6.5 + grinT * 3.5;
        paint.color = _featureColor.withValues(alpha: alpha * 0.80);
        canvas.drawPath(
          Path()
            ..moveTo(cx - hwG, mouthY - rise * morphT)
            ..cubicTo(cx - hwG * 0.35, mouthY + arc * morphT, cx + hwG * 0.35, mouthY + arc * morphT, cx + hwG, mouthY - rise * morphT),
          paint,
        );
        break;
      case AiMood.neutral:
        const hwS = 9.5;
        final tremble = math.sin(whimperT * math.pi * 8) * 1.6;
        paint.color = _featureColor.withValues(alpha: alpha * 0.68);
        canvas.drawPath(
          Path()
            ..moveTo(cx - hwS, mouthY + tremble)
            ..quadraticBezierTo(cx, mouthY - 3.8 * morphT + tremble, cx + hwS, mouthY + tremble),
          paint,
        );
        break;
      case AiMood.concerned:
        final hwD = 10.0 - angerFlashT * 1.6;
        final sag = -2.2 - angerFlashT * 2.6;
        paint.color = _featureColor.withValues(alpha: alpha * (0.58 + 0.20 * angerFlashT));
        canvas.drawPath(
          Path()
            ..moveTo(cx - hwD, mouthY)
            ..quadraticBezierTo(cx, mouthY + sag * morphT, cx + hwD, mouthY),
          paint,
        );
        break;
    }
  }

  // ── Happy: blush cheeks + eye sparkle ───────────────────────
  void _drawBlush(Canvas canvas, double cx, double eyeY, double offX, double alpha) {
    final t = (blushT * alpha).clamp(0.0, 1.0);
    final blushPaint = Paint()
      ..color = _blush.withValues(alpha: t * 0.45)
      ..style = PaintingStyle.fill;
    for (final dx in [-1.0, 1.0]) {
      final bcx = cx + dx * offX * 1.2;
      final bcy = eyeY + 8.0;
      canvas.drawOval(Rect.fromCenter(center: Offset(bcx, bcy), width: 10 * t, height: 6 * t), blushPaint);
    }
    if (t > 0.6) {
      final sp = (t - 0.6) / 0.4;
      final sx = cx + offX + gazeOffset.dx + 1.8;
      final sy = eyeY + gazeOffset.dy - 2.2;
      canvas.drawCircle(Offset(sx, sy), 1.1 * sp, Paint()..color = Colors.white.withValues(alpha: sp * 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant _BlobFacePainter oldDelegate) => true;
}

class _InsightSkeletonLines extends StatefulWidget {
  const _InsightSkeletonLines();

  @override
  State<_InsightSkeletonLines> createState() => _InsightSkeletonLinesState();
}

class _InsightSkeletonLinesState extends State<_InsightSkeletonLines> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.35);
        return Opacity(
          opacity: opacity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _bar(0.9),
              const SizedBox(height: 8),
              _bar(0.75),
              const SizedBox(height: 8),
              _bar(0.5),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(double widthFactor) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(height: 11, decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(4))),
    );
  }
}
