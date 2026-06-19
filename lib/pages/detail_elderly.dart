import 'package:flutter/material.dart';
import 'package:sentinel_new_app/services/service.dart';

class ElderlyDetailPage extends StatefulWidget {
  const ElderlyDetailPage({super.key});

  @override
  State<ElderlyDetailPage> createState() => _ElderlyDetailPageState();
}

class _ElderlyDetailPageState extends State<ElderlyDetailPage> {
  bool _isLoading = true;
  bool _isLoadingCameras = true;
  bool _isLoadingCaregivers = true;
  String? _errorMessage;

  Map<String, dynamic>? _elderly;
  List<dynamic> _cameras = [];
  List<dynamic> _caregivers = [];

  int? _elderlyId;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    _elderlyId = ModalRoute.of(context)?.settings.arguments as int?;

    if (_elderlyId != null) {
      _fetchAllData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'ID lansia tidak valid';
      });
    }
  }

  Future<void> _fetchAllData() async {
    await Future.wait([
      _fetchElderlyDetail(),
      _fetchCameras(),
      _fetchCaregivers(),
    ]);
  }

  Future<void> _fetchElderlyDetail() async {
    try {
      final data = await ApiService.getElderlyById(_elderlyId!);

      setState(() {
        _elderly = data;
      });
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
        return;
      }

      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Tidak dapat terhubung ke server';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchCameras() async {
    try {
      final data = await ApiService.getCamerasByElderly(_elderlyId!);

      setState(() {
        _cameras = data;
      });
    } on ApiException catch (e) {
      if (e.isUnauthorized && mounted) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      // biarkan list kosong
    } catch (_) {
      // biarkan list kosong
    } finally {
      if (mounted) {
        setState(() => _isLoadingCameras = false);
      }
    }
  }

  Future<void> _fetchCaregivers() async {
    try {
      final data = await ApiService.getCaregiversByElderly(_elderlyId!);

      setState(() {
        _caregivers = data;
      });
    } on ApiException catch (e) {
      if (e.isUnauthorized && mounted) {
        Navigator.pushReplacementNamed(context, '/');
        return;
      }

      // biarkan list kosong
    } catch (_) {
      // biarkan list kosong
    } finally {
      if (mounted) {
        setState(() => _isLoadingCaregivers = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Lansia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1A1A2E)),
            onPressed: _fetchAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A1A2E)),
            )
          : _errorMessage != null
          ? _buildErrorView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildCamerasSection(),
                  const SizedBox(height: 16),
                  _buildCaregiversSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFF9CA3AF), size: 48),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchAllData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: const Color(0xFF1A1A2E).withValues(alpha: 0.1),
                child: Text(
                  _getInitials(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _elderly?['full_name'] ?? _elderly?['name'] ?? '-',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_elderly?['age'] != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.cake_outlined,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_elderly?['age']} tahun',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          _buildInfoRow(
            Icons.phone_outlined,
            'Nomor Telepon',
            _elderly?['phone'] ?? _elderly?['phone_number'] ?? '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Alamat',
            _elderly?['address'] ?? '-',
          ),
          const SizedBox(height: 12),
          if (_elderly?['medical_condition'] != null)
            _buildInfoRow(
              Icons.medical_information_outlined,
              'Riwayat Medis',
              _elderly?['medical_condition'] ?? '-',
            ),
          const SizedBox(height: 12),
          if (_elderly?['emergency_contact'] != null)
            _buildInfoRow(
              Icons.emergency_outlined,
              'Kontak Darurat',
              _elderly?['emergency_contact'] ?? '-',
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCamerasSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: Color(0xFF1A1A2E),
                ),
                SizedBox(width: 8),
                Text(
                  'Kamera Terpasang',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingCameras)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            )
          else if (_cameras.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Belum ada kamera terpasang',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            ..._cameras.map((camera) => _buildCameraItem(camera)),
        ],
      ),
    );
  }

  Widget _buildCameraItem(Map<String, dynamic> camera) {
    final cameraId = camera['id'];
    final cameraName =
        camera['name'] ?? camera['camera_name'] ?? 'Kamera ${cameraId ?? ''}';
    final location = camera['location'] ?? '-';
    final status = camera['status'] ?? 'active';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status == 'active' ? Icons.circle : Icons.circle_outlined,
              size: 16,
              color: status == 'active'
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cameraName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigasi ke halaman status frame jika diperlukan
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Info: Camera ID $cameraId'),
                  backgroundColor: const Color(0xFF1A1A2E),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A2E),
            ),
            child: const Text('Lihat', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiversSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: Color(0xFF1A1A2E)),
                SizedBox(width: 8),
                Text(
                  'Caregiver',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoadingCaregivers)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            )
          else if (_caregivers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'Belum ada caregiver',
                  style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                ),
              ),
            )
          else
            ..._caregivers.map((caregiver) => _buildCaregiverItem(caregiver)),
        ],
      ),
    );
  }

  Widget _buildCaregiverItem(Map<String, dynamic> caregiver) {
    final name = caregiver['full_name'] ?? caregiver['name'] ?? '-';
    final role = caregiver['role'] ?? 'Caregiver';
    final phone = caregiver['phone'] ?? '-';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1A1A2E).withValues(alpha: 0.05),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'C',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                if (phone != '-') ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.call_outlined,
              size: 18,
              color: Color(0xFF1A1A2E),
            ),
            onPressed: () {
              // Bisa ditambah fungsi panggilan telepon
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur panggilan akan segera hadir'),
                  backgroundColor: Color(0xFF1A1A2E),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    final fullName = _elderly?['full_name'] ?? _elderly?['name'] ?? '';
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
