import 'package:flutter/material.dart';

class Chapter {
  final String id;
  final String title;
  final String description;
  final String readTime;
  final int cardsCount;
  final IconData icon;
  final List<ChapterPage> pages;

  const Chapter({
    required this.id,
    required this.title,
    required this.description,
    required this.readTime,
    required this.cardsCount,
    required this.icon,
    required this.pages,
  });
}

class ChapterPage {
  final String id;
  final String title;
  final List<ChapterContent> contents;

  const ChapterPage({
    required this.id,
    required this.title,
    required this.contents,
  });
}

abstract class ChapterContent {
  const ChapterContent();
}

class ChapterTextContent extends ChapterContent {
  final String text;
  const ChapterTextContent(this.text);
}

class ChapterTableContent extends ChapterContent {
  final List<String> headers;
  final List<List<String>> rows;
  const ChapterTableContent({required this.headers, required this.rows});
}
