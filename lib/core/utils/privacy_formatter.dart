class PrivacyFormatter {
  static const String cypher = '••••••';

  /// Returns the original string if [isLocked] is false, otherwise returns the [cypher].
  static String obscure(String original, bool isLocked) {
    if (isLocked) return cypher;
    return original;
  }
}
