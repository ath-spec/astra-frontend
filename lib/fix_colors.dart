import 'dart:io';

void main() {
  final files = [
    'lib/features/budget/presentation/widgets/category_bottom_sheet.dart',
    'lib/features/budget/presentation/widgets/category_budget_item.dart',
    'lib/features/budget/presentation/widgets/set_category_bottom_sheet.dart'
  ];

  for (final path in files) {
    final file = File(path);
    if (!file.existsSync()) continue;
    String content = file.readAsStringSync();
    
    // Fix AppAppColors
    content = content.replaceAll('AppAppColors', 'AppColors');
    
    // Fix const AppColors.xxx() -> AppColors.xxx
    content = content.replaceAll(RegExp(r'const\s+AppColors\.([a-zA-Z0-9_]+)\(\)'), r'AppColors.$1');
    content = content.replaceAll(RegExp(r'const\s+AppColors\.([a-zA-Z0-9_]+)'), r'AppColors.$1');

    // Fix black12, black38, black45 which don't exist in AppColors
    // They should probably be AppColors.grey4 or something, or we can just revert to Colors.black12
    content = content.replaceAll('AppColors.black12', 'Colors.black12');
    content = content.replaceAll('AppColors.black38', 'Colors.black38');
    content = content.replaceAll('AppColors.black45', 'Colors.black45');

    file.writeAsStringSync(content);
    print('Fixed \$path');
  }
}
