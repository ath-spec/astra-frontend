import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// Only allows letters, spaces, dots, apostrophes and hyphens (common in names)
class _NameInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final regex = RegExp(r"^[a-zA-Z\s.\'\-]*$");
    if (regex.hasMatch(newValue.text)) return newValue;
    return oldValue;
  }
}

enum _NameError { none, tooShort, invalidChars }

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _aadhaarConfirmed = false;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _onNameChanged() {
    if (!_hasInteracted && _nameController.text.isNotEmpty) {
      setState(() => _hasInteracted = true);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  _NameError get _error {
    final text = _nameController.text.trim();
    if (!_hasInteracted || text.isEmpty) return _NameError.none;
    // Check for invalid chars first (numbers/special characters)
    if (!RegExp(r"^[a-zA-Z\s.\'\-]+$").hasMatch(text)) {
      return _NameError.invalidChars;
    }
    if (text.length < 3) return _NameError.tooShort;
    return _NameError.none;
  }

  bool get _nameValid {
    final text = _nameController.text.trim();
    return text.length >= 3 &&
        text.length <= 14 &&
        RegExp(r"^[a-zA-Z\s.\'\-]+$").hasMatch(text);
  }

  bool get _isEnabled => _nameValid && _aadhaarConfirmed;

  void _submit() {
    if (_isEnabled) context.push('/aa-stocks-otp');
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF111827),
                      size: 20,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (context.canPop()) context.pop();
                    },
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 22),
                          const Text(
                            'Hello,\nmy name is',
                            style: TextStyle(
                              fontFamily: 'SpaceGrotesk',
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                              letterSpacing: -1.0,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Name TextField
                          Transform.translate(
                            offset: const Offset(-4, 0),
                            child: TextField(
                              controller: _nameController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(14),
                                _NameInputFormatter(),
                              ],
                              style: const TextStyle(
                                fontFamily: 'SpaceGrotesk',
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                                color: Color(0xFF111827),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '(type your name)',
                                hintStyle: TextStyle(
                                  fontFamily: 'SpaceGrotesk',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                  color: Color(0xFFD1D5DB),
                                ),
                              ),
                            ),
                          ),
                          // Single fixed-height row: error on left, char count on right.
                          // Always present — zero layout shift.
                          SizedBox(
                            height: 20,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Error message — fades in/out
                                  Expanded(
                                    child: AnimatedOpacity(
                                      opacity: error != _NameError.none ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(
                                        error == _NameError.tooShort
                                            ? 'Min 3 characters required.'
                                            : 'No numbers or special characters.',
                                        style: const TextStyle(
                                          fontFamily: 'DMSans',
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFEF4444),
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Character count — fades in once user starts typing
                                  AnimatedOpacity(
                                    opacity: _hasInteracted && _nameController.text.isNotEmpty ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      '${_nameController.text.trim().length}/14',
                                      style: TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: _nameController.text.trim().length >= 14
                                            ? const Color(0xFFEF4444)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Aadhaar confirmation — radio becomes active once name is valid
                          GestureDetector(
                            onTap: _nameValid
                                ? () => setState(
                                    () => _aadhaarConfirmed = !_aadhaarConfirmed)
                                : null,
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Animated radio/check button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _aadhaarConfirmed
                                          ? const Color(0xFF031E6B)
                                          : _nameValid
                                              ? const Color(0xFF6B7280)
                                              : const Color(0xFFD1D5DB),
                                      width: 1.5,
                                    ),
                                    color: _aadhaarConfirmed
                                        ? const Color(0xFF031E6B)
                                        : Colors.transparent,
                                  ),
                                  child: _aadhaarConfirmed
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 10,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'THIS IS EXACTLY HOW MY NAME APPEARS ON MY AADHAAR.',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                      letterSpacing: 0.8,
                                      color: _nameValid
                                          ? const Color.fromARGB(255, 98, 97, 97)
                                          : const Color.fromARGB(255, 98, 97, 97),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Continue Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: GestureDetector(
                      onTapDown: _isEnabled
                          ? (_) => _animationController.forward()
                          : null,
                      onTapUp: _isEnabled
                          ? (_) => _animationController.reverse()
                          : null,
                      onTapCancel: _isEnabled
                          ? () => _animationController.reverse()
                          : null,
                      onTap: _isEnabled ? _submit : null,
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isEnabled
                                  ? const [
                                      Color(0xFFFFFFFF),
                                      Color(0xFF5BA1F7),
                                      Color(0xFF031E6B),
                                      Color(0xFF241714),
                                    ]
                                  : const [
                                      Color(0xFFF3F4F6),
                                      Color(0xFFD1D5DB),
                                      Color(0xFF9CA3AF),
                                      Color(0xFF6B7280),
                                    ],
                              stops: const [0.0, 0.25, 0.7, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'CONTINUE',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
