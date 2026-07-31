import 'dart:io';

void main() {
  final dir = Directory('lib/features/budget');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Fix AppBudgetColors
    if (content.contains('AppBudgetColors')) {
      content = content.replaceAll('AppBudgetColors', 'BudgetColors');
      modified = true;
    }
    
    // Fix BudgetColors.midGrey2 -> BudgetColors.grey2
    if (content.contains('BudgetColors.midGrey2')) {
      content = content.replaceAll('BudgetColors.midGrey2', 'BudgetColors.grey2');
      modified = true;
    }
    
    // Catch any remaining AppColors
    if (content.contains('AppColors.')) {
      content = content.replaceAll('AppColors.', 'BudgetColors.');
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Fixed in \${file.path}');
    }
  }
}
