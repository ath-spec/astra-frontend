import 'package:flutter/material.dart';
import 'mf_order_item_card.dart';

class MfOrderList extends StatelessWidget {
  const MfOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateHeader('12 FEB'),
        const MfOrderItemCard(
          logoText: 'CANARA\nROBECO',
          logoColor: Color(0xFF0EA5E9), // Sky blue
          fundName: 'Canara Robeco Large Cap Fund',
          amount: '₹22,501.87',
          type: 'BUY',
          status: 'COMPLETED',
        ),
        
        const SizedBox(height: 16),
        _buildDateHeader('9 FEB'),
        const MfOrderItemCard(
          logoText: 'Nippon',
          logoColor: Color(0xFFEF4444), // Red
          fundName: 'Nippon India Large Cap Fund',
          amount: '₹58,191.95',
          type: 'SELL',
          status: 'COMPLETED',
        ),

        const SizedBox(height: 16),
        _buildDateHeader('2 FEB'),
        const MfOrderItemCard(
          logoText: 'CANARA\nROBECO',
          logoColor: Color(0xFF0EA5E9),
          fundName: 'Canara Robeco Large Cap Fund',
          amount: '₹124.99',
          type: 'BUY',
          status: 'COMPLETED',
        ),

        const SizedBox(height: 16),
        _buildDateHeader('27 JAN'),
        const MfOrderItemCard(
          logoText: 'CANARA\nROBECO',
          logoColor: Color(0xFF0EA5E9),
          fundName: 'Canara Robeco Large Cap Fund',
          amount: '₹369.98',
          type: 'BUY',
          status: 'COMPLETED',
        ),

        const SizedBox(height: 16),
        _buildDateHeader('23 JAN'),
        const MfOrderItemCard(
          logoText: 'Nippon',
          logoColor: Color(0xFFEF4444),
          fundName: 'Nippon India Large Cap Fund',
          amount: '₹379.98',
          type: 'BUY',
          status: 'COMPLETED',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
      child: Text(
        date,
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
