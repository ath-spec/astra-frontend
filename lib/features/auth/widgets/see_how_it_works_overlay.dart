import 'package:flutter/material.dart';

/// Modal overlay shown when tapping "See how it works".
/// Displays portfolio tracking benefits, what you get, timeline steps, FAQ accordion, and sticky CTA.
class SeeHowItWorksOverlay extends StatelessWidget {
  const SeeHowItWorksOverlay({this.onGetStarted, super.key});

  final VoidCallback? onGetStarted;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.92;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1017),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Bar with Close Button
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1E28),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ),
          ),
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mockup Card Illustration
                  Center(
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF1B1E28),
                            const Color(0xFF13161F).withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'ASTRA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMockupBar(0.8),
                          const SizedBox(height: 8),
                          _buildMockupBar(0.6),
                          const SizedBox(height: 8),
                          _buildMockupBar(0.4),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Main Headline
                  const Text(
                    'Track and monitor all your investments in one place',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  // Two Grid Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.analytics_outlined,
                          iconColor: const Color(0xFF0D9488), // Teal
                          title: '₹2L Cr+',
                          subtitle: 'of assets\nreviewed',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          icon: Icons.currency_rupee_rounded,
                          iconColor: const Color(0xFFF59E0B), // Amber
                          title: '₹3900 Cr+',
                          subtitle: 'of missed gains\nidentified',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Full Width Security Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161922),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFF10B981),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your data is 100% safe',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'You can unlink your accounts anytime',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                  const SizedBox(height: 36),

                  // Section: What do you get?
                  const Text(
                    'What do you get?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildBenefitItem(
                    icon: Icons.currency_rupee_rounded,
                    iconColor: const Color(0xFF0D9488),
                    textSpans: [
                      const TextSpan(
                        text: 'One view of all your investments and bank ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'accounts at one place',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  _buildBenefitItem(
                    icon: Icons.analytics_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    textSpans: [
                      TextSpan(
                        text: 'Our Experts will help you ',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                      const TextSpan(
                        text: 'identify critical issues in your portfolio, ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'and how to fix them',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  _buildBenefitItem(
                    icon: Icons.notifications_active_outlined,
                    iconColor: const Color(0xFF10B981),
                    textSpans: [
                      const TextSpan(
                        text: 'Regular insights and key alerts ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: 'on how your money moves',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  _buildReviewBanner(),
                  const SizedBox(height: 36),
                  Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                  const SizedBox(height: 36),

                  // Section: Step-by-Step Flow / Timeline
                  _buildTimelineStep(
                    stepNumber: 1,
                    title: 'Verify phone number & PAN',
                    subtitle: 'Add the phone number linked to your PAN',
                  ),
                  _buildTimelineStep(
                    stepNumber: 2,
                    title: 'Fetch your Mutual Fund holdings',
                    subtitle:
                        'We fetch your mutual fund data securely using either CAMS & KFintech’s MF Central platform or RBI’s Account Aggregator framework, depending on the best available source at the time.',
                  ),
                  _buildTimelineStep(
                    stepNumber: 3,
                    title: 'Fetch your Stocks & Bank accounts',
                    subtitle: 'We use the Account Aggregator framework to fetch this data securely',
                    isLast: true,
                  ),
                  const SizedBox(height: 36),
                  Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                  const SizedBox(height: 36),

                  // Section: Frequently Asked Questions
                  const Text(
                    'Frequently asked questions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FaqAccordion(
                    question: 'What is MF Central?',
                    initiallyExpanded: true,
                    answer:
                        'MF Central is a platform that lets you manage all your mutual funds in one place. Created by KFintech and CAMS, it helps you view your portfolio, check statements, and handle service requests easily.',
                  ),
                  const _FaqAccordion(
                    question: 'What is Account Aggregator?',
                    answer:
                        'The Account Aggregator (AA) framework established by RBI allows individuals to securely share their financial data from various accounts like banks, insurance, and investments with third-party financial service providers. This is done with the user\'s explicit consent and helps in making personalised financial decisions.',
                  ),
                  const _FaqAccordion(
                    question: 'How do we keep your data secure?',
                    answer:
                        'At Astra, your data is protected with AES-256 encryption, secure servers, and industry-standard protocols. We conduct regular audits, use multi-factor authentication, and uphold the highest security standards with ISO 27001 certification.',
                  ),
                  const _FaqAccordion(
                    question: 'How do I stop tracking my accounts?',
                    answer:
                        'You can stop sharing your data whenever you want by going to your profile and deleting your account.',
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // Sticky Docked Bottom CTA Button
          Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1017),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                onGetStarted?.call();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFF5BA1F7),
                      Color(0xFF031E6B),
                      Color(0xFF241714),
                    ],
                    stops: [0.0, 0.25, 0.7, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'GET STARTED',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Positioned(
                      right: 20,
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockupBar(double widthFraction) {
    return FractionallySizedBox(
      widthFactor: widthFraction,
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required Color iconColor,
    required List<InlineSpan> textSpans,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  children: textSpans,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=faces'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Color(0xFF0D1017),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'See why you should review\nyour portfolio regularly?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white54,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepNumber,
    required String title,
    required String subtitle,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: Colors.white.withValues(alpha: 0.12),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqAccordion extends StatefulWidget {
  const _FaqAccordion({
    required this.question,
    required this.answer,
    this.initiallyExpanded = false,
  });

  final String question;
  final String answer;
  final bool initiallyExpanded;

  @override
  State<_FaqAccordion> createState() => _FaqAccordionState();
}

class _FaqAccordionState extends State<_FaqAccordion> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: Colors.white70,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 18, right: 16),
              child: Text(
                widget.answer,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
