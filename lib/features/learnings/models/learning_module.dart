import 'package:flutter/material.dart';

class LearningModule {
  final int id;
  final String title;
  final String description;
  final Color themeColor;

  const LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.themeColor,
  });
}

const List<LearningModule> learningModules = [
  LearningModule(
    id: 1,
    title: '1. Stock Market Basics',
    description: 'Start with this module if you are a market newbie. This module will help you understand the market basics including the IPO markets, commonly used jargons, trading terminal, and market events.',
    themeColor: Color(0xFF4ADE80), // Green
  ),
  LearningModule(
    id: 2,
    title: '2. Technical Analysis',
    description: 'This comprehensive module on \'Technical Analysis\' helps you understand the Japanese candlestick patterns, volume analysis, support, resistance, indicators, risk-reward ratio, and the Dow Theory.',
    themeColor: Color(0xFFF472B6), // Pink
  ),
  LearningModule(
    id: 3,
    title: '3. Futures Trading',
    description: 'This module helps you develop a comprehensive understanding of how the \'Futures Contract\' is structured and traded in the Indian derivative market.',
    themeColor: Color(0xFFFACC15), // Yellow
  ),
  LearningModule(
    id: 4,
    title: '4. Options Trading',
    description: 'This comprehensive module on \'Options Theory\', covers topics ranging from the very basics to advanced options trading concepts.',
    themeColor: Color(0xFFA78BFA), // Purple
  ),
  LearningModule(
    id: 5,
    title: '5. Fundamental analysis',
    description: 'Fundamental analysis (FA)is a holistic approach to study a business. This module will show you how to evaluate a business by studying the different aspects of the same.',
    themeColor: Color(0xFF2DD4BF), // Cyan
  ),
  LearningModule(
    id: 6,
    title: '6. Option Strategies',
    description: 'The module covers various options strategies that can be built with a multi-dimensional approach based on Market trend involving Option Greeks, Risk-Return, etc.',
    themeColor: Color(0xFFFDA4AF), // Light Pink
  ),
  LearningModule(
    id: 7,
    title: '7. Currency, Commodity, and Govt Securities',
    description: 'In this module, you will learn about the comprehensive orientation of Currency contracts, MCX Commodity contracts, and the G-Secs traded in the Indian Markets.',
    themeColor: Color(0xFFFB923C), // Orange
  ),
  LearningModule(
    id: 8,
    title: '8. Markets and Taxation',
    description: 'As a trader in India, you should be informed of all the taxes that are levied on your investments and account. This module overlays the taxation countenance of Investing/Trading in the Markets.',
    themeColor: Color(0xFF2DD4BF), // Teal
  ),
  LearningModule(
    id: 9,
    title: '9. Risk Management and Trading Psychology',
    description: 'The module covers the risk management aspect along with the psychology required for being consistent and profitable while trading.',
    themeColor: Color(0xFF4ADE80), // Green
  ),
  LearningModule(
    id: 10,
    title: '10. Trading Systems',
    description: 'In this module, we will learn about all the major components of Trading Systems and much more including the techniques and its different types.',
    themeColor: Color(0xFFF472B6), // Pink
  ),
  LearningModule(
    id: 11,
    title: '11. Personal Finance',
    description: 'Personal finance is an essential aspect of your financial life in this module you will learn the various aspects of personal finance such as retirement planning, Mutual funds, ETFs, Bonds, and goal-oriented investments.',
    themeColor: Color(0xFFFACC15), // Yellow
  ),
  LearningModule(
    id: 12,
    title: '12. Personal Finance - Insurance',
    description: 'In this module, we will dive deep into insurance concepts and learn their importance in our life.',
    themeColor: Color(0xFFA78BFA), // Purple
  ),
  LearningModule(
    id: 13,
    title: '13. Innerworth - Mind over markets',
    description: 'A series of articles on the psychology of trading, that will guide you, mend your thoughts and prepare you psychologically to become a novice trader.',
    themeColor: Color(0xFF4ADE80), // Green
  ),
];
