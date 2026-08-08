import 'dart:io';

void main() {
  final dir = Directory('lib/features/recurring');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final stringLowerRegex = RegExp(r'"([^"]+)"\.toLowerCase\(\)');
  final stringLowerSingleRegex = RegExp(r"'([^']+)'\.toLowerCase\(\)");

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    String newContent = content.replaceAllMapped(stringLowerRegex, (match) {
      String text = match.group(1)!;
      if (text.isNotEmpty) {
        text = text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
      }
      modified = true;
      return '"$text"';
    });

    newContent = newContent.replaceAllMapped(stringLowerSingleRegex, (match) {
      String text = match.group(1)!;
      if (text == 'active' || text == 'paused' || text == 'cancelled' || text == 'trial') {
        // Keep these if you want
      }
      if (text.isNotEmpty) {
        text = text.substring(0, 1).toUpperCase() + text.substring(1).toLowerCase();
      }
      modified = true;
      return "'$text'";
    });

    if (modified) {
      file.writeAsStringSync(newContent);
      print('Updated ${file.path}');
    }
  }
}
