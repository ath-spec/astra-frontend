import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../features/chat/widgets/astra_data_card.dart';
import '../../features/chat/widgets/astra_chart_card.dart';

class TypewriterMarkdown extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final bool animate;
  final VoidCallback? onTypingStarted;
  final VoidCallback? onTypingFinished;

  const TypewriterMarkdown({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 15),
    this.animate = true,
    this.onTypingStarted,
    this.onTypingFinished,
  });

  @override
  State<TypewriterMarkdown> createState() => _TypewriterMarkdownState();
}

class _TypewriterMarkdownState extends State<TypewriterMarkdown> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer?.cancel();
    if (!widget.animate) {
      _displayedText = widget.text;
      _currentIndex = widget.text.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTypingFinished?.call();
      });
      return;
    }
    
    _currentIndex = 0;
    _displayedText = '';
    
    // Defer the callback to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onTypingStarted?.call();
    });
    
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_currentIndex];
            _currentIndex++;
          });
        }
      } else {
        timer.cancel();
        if (mounted) widget.onTypingFinished?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant TypewriterMarkdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.animate && !widget.animate) {
      // Interrupted! Finish typing instantly.
      _timer?.cancel();
      setState(() {
        _displayedText = widget.text;
        _currentIndex = widget.text.length;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTypingFinished?.call();
      });
    } else if (oldWidget.text != widget.text && widget.animate) {
      _startTyping();
    } else if (oldWidget.text != widget.text && !widget.animate) {
      setState(() {
        _displayedText = widget.text;
        _currentIndex = widget.text.length;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onTypingFinished?.call();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? const TextStyle(fontFamily: 'DMSans');
    return MarkdownBody(
      data: _displayedText,
      styleSheet: MarkdownStyleSheet(
        p: baseStyle,
        // Premium Table Styling
        tableBody: baseStyle.copyWith(fontSize: 13, color: const Color(0xFF334155)),
        tableHead: baseStyle.copyWith(
          fontSize: 12, 
          fontWeight: FontWeight.w700, 
          color: const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
        tableHeadAlign: TextAlign.left,
        tableCellsPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        tableBorder: const TableBorder(
          horizontalInside: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        tableColumnWidth: const IntrinsicColumnWidth(),
        codeblockDecoration: const BoxDecoration(color: Colors.transparent),
        codeblockPadding: EdgeInsets.zero,
      ),
      builders: {
        'code': AstraJsonWidgetBuilder(),
      },
    );
  }
}

class AstraJsonWidgetBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final String textContent = element.textContent.trim();
    
    // Check if it's a JSON block
    if (element.attributes['class'] == 'language-json') {
      try {
        final data = jsonDecode(textContent);
        if (data is Map<String, dynamic>) {
          if (data['type'] == 'table') {
            return AstraDataCard(
              title: data['title'] as String?,
              columns: (data['columns'] as List).cast<String>(),
              rows: (data['rows'] as List).map((row) => (row as List).cast<String>()).toList(),
            );
          } else if (data['type'] == 'chart') {
            return AstraChartCard(
              title: data['title'] as String?,
              chartType: data['chartType'] ?? 'pie',
              data: Map<String, dynamic>.from(data['data']),
            );
          }
        }
      } catch (e) {
        // Fallback to standard code rendering below
      }
    }

    // Fallback for standard code blocks (inline or fenced)
    final isInline = !textContent.contains('\n');
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isInline ? 4 : 12, vertical: isInline ? 2 : 12),
      margin: isInline ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(isInline ? 4 : 8),
        border: isInline ? null : Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          textContent,
          style: const TextStyle(
            fontFamily: 'DMMono', // Generic monospace fallback
            fontSize: 13,
            color: Color(0xFF334155),
          ),
        ),
      ),
    );
  }
}
