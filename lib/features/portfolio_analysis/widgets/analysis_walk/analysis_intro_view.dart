import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../chat/widgets/thinking_orbs/thinking_orb.dart';

class AnalysisIntroView extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onNext;

  const AnalysisIntroView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onNext,
  });

  @override
  State<AnalysisIntroView> createState() => _AnalysisIntroViewState();
}
class _AnalysisIntroViewState extends State<AnalysisIntroView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: ThinkingOrb(
              mode: 'ribbon', // The analytical 'thinking' mode
              size: 140,
              color: const Color.fromARGB(255, 0, 0, 0), // Match the CTA primary color for consistency
            ),
          ),
        ),
        
        // Text Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 48),
        
        // Gradient CTA Button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: GestureDetector(
            onTap: () {
              widget.onNext();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.black,
              ),
              child: Center(
                child: Text(
                  'Show My ${widget.title} \u2192',
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
