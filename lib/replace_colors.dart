import 'dart:io';

void main() {
  final dir = Directory('lib/features/budget');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  final Map<RegExp, String> replacements = {
    RegExp(r'Color\(0xFFebe9ea\)', caseSensitive: false): 'AppColors.grey2',
    RegExp(r'Color\(0xFF282828\)', caseSensitive: false): 'AppColors.foreground',
    RegExp(r'Colors\.black87'): 'AppColors.foreground',
    RegExp(r'Colors\.black54'): 'AppColors.grey7',
    RegExp(r'Colors\.black'): 'AppColors.black',
    RegExp(r'Colors\.white'): 'AppColors.white',
    RegExp(r'Color\(0xFF6A1B9A\)', caseSensitive: false): 'AppColors.primaryPurple',
    RegExp(r'Color\(0xFF9C27B0\)', caseSensitive: false): 'AppColors.lightPurple',
    RegExp(r'Color\(0xFF4A148C\)', caseSensitive: false): 'AppColors.deepPurple',
    RegExp(r'Color\(0xFFE8F5E9\)', caseSensitive: false): 'AppColors.successBg',
    RegExp(r'Color\(0xFF4CAF50\)', caseSensitive: false): 'AppColors.successText',
    RegExp(r'Color\(0xFFF44336\)', caseSensitive: false): 'AppColors.errorText',
    RegExp(r'Color\(0xFFD32F2F\)', caseSensitive: false): 'AppColors.errorTextDark',
    RegExp(r'Color\(0xFFFFEBEE\)', caseSensitive: false): 'AppColors.errorBg',
    RegExp(r'Colors\.red\[\d+\]!'): 'AppColors.errorText',
    RegExp(r'Colors\.red'): 'AppColors.errorText',
    RegExp(r'Colors\.green\[\d+\]!'): 'AppColors.successText',
    RegExp(r'Colors\.green'): 'AppColors.successText',
    RegExp(r'Colors\.grey\[(\d+)\]!'): 'AppColors.midGrey',
    RegExp(r'Colors\.grey'): 'AppColors.midGrey',
    RegExp(r'Color\(0xFFD6FF3F\)', caseSensitive: false): 'AppColors.neonGreen',
    RegExp(r'Color\(0xFF1F1F1F\)', caseSensitive: false): 'AppColors.toggleBlack',
    RegExp(r'Color\(0xFFE0F7E9\)', caseSensitive: false): 'AppColors.mintGreen',
    RegExp(r'Color\(0xFF1B5E20\)', caseSensitive: false): 'AppColors.darkGreen',
  };

  int replacedCount = 0;

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    // Check if file uses any of these colors and doesn't already import app_colors
    bool needsImport = false;
    for (final pattern in replacements.keys) {
      if (pattern.hasMatch(content)) {
        content = content.replaceAll(pattern, replacements[pattern]!);
        modified = true;
        needsImport = true;
      }
    }

    if (modified) {
      if (needsImport && !content.contains('app_colors.dart')) {
        // Add import
        content = "import 'package:astra_frontend/core/theme/app_colors.dart';\n" + content;
      }
      file.writeAsStringSync(content);
      replacedCount++;
      print('Updated \${file.path}');
    }
  }

  print('Replaced colors in \$replacedCount files.');
}
