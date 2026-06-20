import 'package:flutter/material.dart';
import 'package:sentinel_new_app/services/service.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<dynamic> _events = [];
  bool _isLoading = true;
  String? _error;

  static const String baseUrl = 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final events = await ApiService.getFallEvents();
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat riwayat kejadian.';
        _isLoading = false;
      });
    }
  }

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A2E)),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadEvents, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_outlined, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 12),
            Text(
              'Belum ada kejadian jatuh',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) => _buildEventCard(_events[index]),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final snapshotUrl = event['snapshot_url'];
    final hasSnapshot = snapshotUrl != null;
    final confidenceScore = event['confidence_score'];
    final confidenceText = confidenceScore != null
    ? '${(double.parse(confidenceScore.toString()) * 100).toStringAsFixed(1)}%'
    : '-';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Snapshot
          if (hasSnapshot)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                '$baseUrl$snapshotUrl',
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180,
                  color: const Color(0xFFE5E7EB),
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Color(0xFF9CA3AF), size: 48),
                  ),
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 100,
                color: const Color(0xFFFFE4E4),
                child: const Center(
                  child: Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 48),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '🚨 Jatuh Terdeteksi',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Nama lansia
                Text(
                  event['elderly_name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),

                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      event['location'] ?? '-',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Waktu
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      event['event_time']?.toString() ?? '-',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Confidence score
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      'Keyakinan AI: $confidenceText',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}