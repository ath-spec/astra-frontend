import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bottom sheet shown when the user taps the edit pencil on the AA Stocks OTP
/// screen. Allows entering/changing the mobile number used for OTP.
class EditNumberOverlay extends StatefulWidget {
  final String currentNumber;
  final ValueChanged<String>? onConfirm;

  const EditNumberOverlay({
    super.key,
    required this.currentNumber,
    this.onConfirm,
  });

  @override
  State<EditNumberOverlay> createState() => _EditNumberOverlayState();
}

class _EditNumberOverlayState extends State<EditNumberOverlay> {
  late final TextEditingController _controller;
  bool get _isValid => _controller.text.length == 10;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNumber);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Lift sheet above keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          top: 12,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Change number',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'ENTER THE MOBILE NUMBER YOU WANT TO USE FOR OTP VERFICATION.',
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                color: Color(0xFF6B7280),
                height: 1.4,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Phone input field
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'INDIA',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1D5DB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '+91',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [
                        Color(0xFF5BA1F7),
                        Color(0xFF031E6B),
                        Color(0xFF241714),
                      ],
                      stops: [0.0, 0.5, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  hintText: '9876543210',
                  hintStyle: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    foreground: Paint()..color = const Color(0xFFE5E7EB),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Helper text
            Row(
              children: const [
                Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: Color(0xFF9CA3AF),
                ),
                SizedBox(width: 6),
                Text(
                  'A NEW OTP WILL BE SENT TO THIS NUMBER.',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // CTA
            GestureDetector(
              onTap: _isValid
                  ? () {
                      Navigator.of(context).pop();
                      widget.onConfirm?.call(_controller.text);
                    }
                  : null,
              child: Opacity(
                opacity: _isValid ? 1.0 : 0.4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFF5BA1F7),
                        Color(0xFF031E6B),
                        Color(0xFF241714),
                      ],
                      stops: [0.0, 0.25, 0.7, 1.0],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'SEND OTP',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Positioned(
                        right: 20,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
