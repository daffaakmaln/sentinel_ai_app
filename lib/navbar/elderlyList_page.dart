import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ─────────────────────────────────────────────
// TAB 1: List Lansia
// ─────────────────────────────────────────────
class ElderlyListPage extends StatefulWidget {
  const ElderlyListPage({super.key});

  @override
  State<ElderlyListPage> createState() => ElderlyListPageState();
}

class ElderlyListPageState extends State<ElderlyListPage> {
  static const String _baseUrl = 'http://localhost:3000';

  List<dynamic> _elderlyList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchElderly();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchElderly() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/elderly'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _elderlyList = data is List ? data : (data['data'] ?? []);
        });
      } else if (response.statusCode == 401) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() => _errorMessage = 'Gagal memuat data.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteElderly(int id) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/elderly/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        _fetchElderly();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data lansia berhasil dihapus'),
              backgroundColor: Color(0xFF1A1A2E),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menghapus data')));
      }
    }
  }

  void _showDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Hapus Data',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text('Hapus data "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteElderly(id);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Color(0xFFDC2626)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Data Lansia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: _fetchElderly,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/elderly/add');
          if (result == true) _fetchElderly();
        },
        backgroundColor: const Color.fromARGB(255, 25, 153, 199),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color.fromARGB(255, 25, 153, 199)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFF9CA3AF),
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchElderly,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 25, 153, 199),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            )
          : _elderlyList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Color(0xFF9CA3AF),
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada data lansia',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + untuk menambahkan',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchElderly,
              color: const Color.fromARGB(255, 25, 153, 199),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _elderlyList.length,
                itemBuilder: (context, index) {
                  final elderly = _elderlyList[index];
                  final id = elderly['id'];
                  final name = elderly['full_name'] ?? elderly['name'] ?? '-';
                  final age = elderly['age']?.toString() ?? '-';
                  final address = elderly['address'] ?? '-';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: const Color(
                          0xFF1A1A2E,
                        ).withValues(alpha: 0.1),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 25, 153, 199),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.cake_outlined,
                                size: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$age tahun',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF9CA3AF),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: 'detail',
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 16),
                                SizedBox(width: 8),
                                Text('Detail', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Edit', style: TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: Color(0xFFDC2626),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) async {
                          if (value == 'delete') {
                            _showDeleteDialog(id, name);
                          } else if (value == 'detail') {
                            Navigator.pushNamed(
                              context,
                              '/elderly/detail',
                              arguments: id,
                            );
                          } else if (value == 'edit') {
                            final result = await Navigator.pushNamed(
                              context,
                              '/elderly/edit',
                              arguments: elderly,
                            );

                            // Jika result true (update berhasil), refresh data
                            if (result == true) {
                              _fetchElderly(); // Refresh list
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
