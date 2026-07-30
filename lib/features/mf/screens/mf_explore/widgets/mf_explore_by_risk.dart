import 'package:flutter/material.dart';

class MfExploreByRisk extends StatefulWidget {
  const MfExploreByRisk({super.key});

  @override
  State<MfExploreByRisk> createState() => _MfExploreByRiskState();
}

class _MfExploreByRiskState extends State<MfExploreByRisk> {
  double _currentValue = 1.0; // Moderate default

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Explore By Risk',
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // Slider Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Safe',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                'Aggressive',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        
        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF8B5CF6), // Softer purple
            inactiveTrackColor: const Color(0xFFF1F5F9),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF8B5CF6).withOpacity(0.1),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 4.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: _currentValue,
            min: 0,
            max: 3,
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Cards Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: _buildRiskCard(
                  title: 'Conservative',
                  subtitle: 'Lower Risk',
                  icon: Icons.shield_rounded,
                  isActive: _currentValue.round() == 0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRiskCard(
                  title: 'Moderate',
                  subtitle: 'Balanced\nApproach',
                  icon: Icons.balance_rounded,
                  isActive: _currentValue.round() == 1,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRiskCard(
                  title: 'Growth',
                  subtitle: 'Higher\nPotential',
                  icon: Icons.trending_up_rounded,
                  isActive: _currentValue.round() == 2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildRiskCard(
                  title: 'Aggressive',
                  subtitle: 'Maximum\nGrowth',
                  icon: Icons.rocket_launch_rounded,
                  isActive: _currentValue.round() == 3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF5F3FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF8B5CF6).withOpacity(0.5) : const Color(0xFFF1F5F9),
          width: 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF8B5CF6) : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: isActive ? const Color(0xFF8B5CF6) : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF8B5CF6).withOpacity(0.8) : const Color(0xFF94A3B8),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
