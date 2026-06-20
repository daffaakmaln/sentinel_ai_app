import 'package:flutter/material.dart';
import 'package:sentinel_new_app/services/service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _user = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await ApiService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.logout();
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
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
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color.fromARGB(255, 25, 153, 199),
                    child: Text(
                      (_user['full_name'] as String? ?? '?')[0].toUpperCase(),
                      style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _user['full_name'] ?? '-',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user['email'] ?? '-',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),

                  // Info card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                    child: Column(
                      children: [
                        _buildInfoTile(Icons.person_outline, 'Nama Lengkap', _user['full_name'] ?? '-'),
                        const Divider(height: 1),
                        _buildInfoTile(Icons.email_outlined, 'Email', _user['email'] ?? '-'),
                        const Divider(height: 1),
                        _buildInfoTile(Icons.badge_outlined, 'User ID', '#${_user['id'] ?? '-'}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 25, 153, 199)),
      title: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w500)),
    );
  }
}