import 'package:flutter/material.dart';

class MfBondsFaq extends StatelessWidget {
  const MfBondsFaq({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Frequently asked questions',
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 16),
          _FaqItem(
            question: 'What documents are needed to start investing?',
            answer: 'The following documents are required for the one-time KYC process: PAN card, Aadhaar card, bank account details, and an existing Demat account.',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _FaqItem(
            question: 'What is YTM?',
            answer: 'YTM (Yield to Maturity) is the expected annual return on a bond if held until maturity, taking into account its current market price and interest payments.',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _FaqItem(
            question: 'When will I receive securities in my Demat account?',
            answer: 'You will typically receive the securities on the next working day after placing your investment order, provided the payment has been completed.',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _FaqItem(
            question: 'Can I sell my bonds before maturity?',
            answer: 'Yes, bonds can be sold anytime on the exchange, subject to the availability of buyers.',
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'By proceeding, I agree to Terms & Conditions and\nUser Declaration',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: 10,
                color: const Color(0xFF94A3B8), // slate 400
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.remove : Icons.add,
                  color: const Color(0xFF00C75A),
                  size: 20,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 24.0),
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
            ),
          ],
        ),
      ),
    );
  }
}
