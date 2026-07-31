import 'dart:io';

void main() {
  final dir = Directory('lib/features/budget');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('AppColors')) {
      content = content.replaceAll('AppColors', 'BudgetColors');
      modified = true;
    }
    
    if (content.contains('package:astra_frontend/core/theme/app_colors.dart')) {
      content = content.replaceAll(
          'package:astra_frontend/core/theme/app_colors.dart',
          'package:astra_frontend/features/budget/theme/budget_colors.dart');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Renamed colors in \${file.path}');
    }
  }

  final oldFile = File('lib/core/theme/app_colors.dart');
  if (oldFile.existsSync()) {
    oldFile.deleteSync();
    print('Deleted old app_colors.dart');
  }
}
