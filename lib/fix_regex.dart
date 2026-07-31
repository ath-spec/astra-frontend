import 'dart:io';

void main() {
  final dir = Directory('lib/features/budget');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains(r'BudgetColors.$1')) {
      // The original one that threw the const constructor error was lightPurple
      content = content.replaceAll(r'BudgetColors.$1', 'BudgetColors.lightPurple');
      modified = true;
    }
    if (content.contains('midGrey7')) {
      content = content.replaceAll('midGrey7', 'grey7');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed in \${file.path}');
    }
  }
}
