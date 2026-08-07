import 'package:flutter/foundation.dart';
import '../models/chapter_models.dart';

class LearningProgressService extends ChangeNotifier {
  static final LearningProgressService instance = LearningProgressService._internal();
  LearningProgressService._internal();

  final Map<String, Set<String>> _completedPages = {};

  void markPageComplete(String chapterId, String pageId) {
    if (!_completedPages.containsKey(chapterId)) {
      _completedPages[chapterId] = {};
    }
    if (!_completedPages[chapterId]!.contains(pageId)) {
      _completedPages[chapterId]!.add(pageId);
      notifyListeners();
    }
  }

  int getLevelProgress(List<Chapter> levelChapters) {
    int totalPages = 0;
    int completed = 0;
    for (var chapter in levelChapters) {
      totalPages += chapter.pages.length;
      if (_completedPages.containsKey(chapter.id)) {
        completed += _completedPages[chapter.id]!.length;
      }
    }
    if (totalPages == 0) return 0;
    return ((completed / totalPages) * 100).round();
  }

  int getChapterProgress(Chapter chapter) {
    int totalPages = chapter.pages.length;
    if (totalPages == 0) return 0;
    
    int completed = 0;
    if (_completedPages.containsKey(chapter.id)) {
      completed = _completedPages[chapter.id]!.length;
    }
    return ((completed / totalPages) * 100).round();
  }
}
