import 'package:flutter/material.dart';

/// Modal bottom sheet overlay shown when tapping "Why PAN?" or "Know more".
/// Explains why PAN is needed and highlights data security and ease of use.
class WhyPanOverlay extends StatelessWidget {
  const WhyPanOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1017),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title and Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Why PAN Number?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF1B1E28),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Item 1: Fetch your data in just few clicks
            _buildReasonItem(
              icon: Icons.description_rounded,
              iconColor: const Color(0xFFF59E0B), // Amber
              title: 'Fetch your data in just few clicks',
              subtitle: 'No hassle of forwarding email reports',
            ),
            const SizedBox(height: 20),
            // Item 2: All investments linked to PAN & mobile
            _buildReasonItem(
              icon: Icons.mark_email_read_rounded,
              iconColor: const Color(0xFF0D9488), // Teal
              title: 'All investments linked to PAN & mobile',
              subtitle: 'Including all your past holdings',
            ),
            const SizedBox(height: 20),
            // Item 3: Your data is kept secure
            _buildReasonItem(
              icon: Icons.lock_rounded,
              iconColor: const Color(0xFF10B981), // Green
              title: 'Your data is kept secure',
              subtitle: 'You can delete your data anytime',
            ),
            const SizedBox(height: 32),
            // I understand Button
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'I understand',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Footer: Powered by Pirimid Fintech
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Powered by ',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                Icon(
                  Icons.change_history_rounded,
                  color: const Color(0xFF38BDF8), // Blue pyramid icon
                  size: 14,
                ),
                const Text(
                  ' Pirimid Fintech',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasonItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
