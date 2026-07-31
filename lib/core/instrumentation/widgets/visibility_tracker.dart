import 'package:flutter/material.dart';

class ZeyroVisibilityTracker extends StatelessWidget {
  final String eventName;
  final Widget child;
  
  const ZeyroVisibilityTracker({super.key, required this.eventName, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
