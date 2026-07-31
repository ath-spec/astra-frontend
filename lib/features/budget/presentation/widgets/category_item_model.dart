import 'package:flutter/material.dart';

class CategoryItem {
  final String? categoryId; // UUID or Slug
  final String title;
  final IconData icon;
  final Color iconColor;
  final double suggestedAmount;
  final Color? cardColor;
  final Color? cardTextColor;
  bool isSet;

  CategoryItem({
    this.categoryId,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.suggestedAmount,
    this.cardColor,
    this.cardTextColor,
    this.isSet = false,
  });
}
