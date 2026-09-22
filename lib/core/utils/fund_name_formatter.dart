/// Utility to clean up redundant AMFI suffixes (e.g. "- Growth", "- Direct Plan - Growth")
/// from mutual fund display names so the identifying fund name fits cleanly on cards.
String cleanFundName(String raw) {
  if (raw.isEmpty) return raw;
  var cleaned = raw;
  
  final patterns = [
    RegExp(r'\s*-\s*Direct\s*Plan\s*-\s*Growth(\s*Option)?', caseSensitive: false),
    RegExp(r'\s*-\s*Regular\s*Plan\s*-\s*Growth(\s*Option)?', caseSensitive: false),
    RegExp(r'\s*-\s*Direct\s*Growth(\s*Option)?', caseSensitive: false),
    RegExp(r'\s*-\s*Regular\s*Growth(\s*Option)?', caseSensitive: false),
    RegExp(r'\s*-\s*Growth\s*Option', caseSensitive: false),
    RegExp(r'\s*-\s*Growth\b', caseSensitive: false),
    RegExp(r'\s+Direct\s+Plan\s+Growth', caseSensitive: false),
    RegExp(r'\s+Direct\s+Growth', caseSensitive: false),
    RegExp(r'\s+Regular\s+Growth', caseSensitive: false),
  ];
  
  for (final p in patterns) {
    cleaned = cleaned.replaceAll(p, '');
  }
  
  return cleaned.trim();
}
