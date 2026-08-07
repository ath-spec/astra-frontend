import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global privacy toggle state. True means values are obscured.
final privacyProvider = StateProvider<bool>((ref) => false);
