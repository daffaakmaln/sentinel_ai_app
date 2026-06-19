import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// TAB 3: Kejadian (placeholder)
// ─────────────────────────────────────────────
class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Riwayat Kejadian',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_outlined,
                size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'Riwayat Kejadian Jatuh',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Segera hadir',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}