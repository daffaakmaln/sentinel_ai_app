import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ElderlyEditPage extends StatefulWidget {
  const ElderlyEditPage({super.key});

  @override
  State<ElderlyEditPage> createState() => _ElderlyEditPageState();
}

class _ElderlyEditPageState extends State<ElderlyEditPage> {
  static const String _baseUrl = 'http://localhost:3000';

  final _formKey = GlobalKey<FormState>();
  
  Map<String, dynamic>? _elderly;
  int? _elderlyId;
  
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender; // Tambahan
  final _addressController = TextEditingController();
  final _healthConditionController = TextEditingController(); // Ganti dari medical_condition
  final _notesController = TextEditingController(); // Tambahan
  
  bool _initialized = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  // List gender options

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is Map<String, dynamic>) {
      _elderly = args;
      _elderlyId = _elderly?['id'];
      _populateForm();
      setState(() => _isLoading = false);
    } else if (args is int) {
      _elderlyId = args;
      _fetchElderlyData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Data lansia tidak valid';
      });
    }
  }

  void _populateForm() {
    _fullNameController.text = _elderly?['full_name'] ?? _elderly?['name'] ?? '';
    _ageController.text = (_elderly?['age'] ?? '').toString();
    _selectedGender = _elderly?['gender'] ?? _elderly?['jenis_kelamin'];
    _addressController.text = _elderly?['address'] ?? '';
    _healthConditionController.text = _elderly?['health_condition'] ?? _elderly?['medical_condition'] ?? '';
    _notesController.text = _elderly?['notes'] ?? _elderly?['catatan'] ?? '';
  }

  Future<void> _fetchElderlyData() async {
    final token = await _getToken();
    if (token == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/elderly/$_elderlyId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _elderly = data is Map ? data : (data['data'] ?? {});
          _populateForm();
        });
      } else if (response.statusCode == 401) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() => _errorMessage = 'Gagal memuat data lansia');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _updateElderly() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final token = await _getToken();
    if (token == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/');
      return;
    }

    // ✅ Sesuai dengan struktur SQL: full_name, age, gender, address, health_condition, notes
    final body = {
      'full_name': _fullNameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'gender': _selectedGender,
      'address': _addressController.text.trim(),
      'health_condition': _healthConditionController.text.trim(),
      'notes': _notesController.text.trim(),
    };

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/elderly/$_elderlyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data lansia berhasil diperbarui'),
              backgroundColor: Color(0xFF22C55E),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        _showErrorDialog(error['message'] ?? 'Data tidak valid');
      } else if (response.statusCode == 401) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
      } else {
        _showErrorDialog('Gagal memperbarui data');
      }
    } catch (e) {
      _showErrorDialog('Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Gagal', style: TextStyle(fontSize: 16)),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF1A1A2E))),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Data Lansia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        actions: [
          if (!_isLoading && _errorMessage == null)
            TextButton(
              onPressed: _isSubmitting ? null : _updateElderly,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF1A1A2E),
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildFormCard(),
                        const SizedBox(height: 80),
                      ],
                    ),
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
          Text(_errorMessage!,
              style: const TextStyle(color: Color(0xFF6B7280))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchElderlyData,
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

  Widget _buildFormCard() {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: Color(0xFF1A1A2E)),
              SizedBox(width: 8),
              Text(
                'Informasi Pribadi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          
          // Nama Lengkap
          _buildTextField(
            controller: _fullNameController,
            label: 'Nama Lengkap',
            icon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nama lengkap harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Usia
          _buildTextField(
            controller: _ageController,
            label: 'Usia (tahun)',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Usia harus diisi';
              }
              if (int.tryParse(value) == null) {
                return 'Usia harus berupa angka';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Gender (Dropdown - TAMBAHAN)
          _buildGenderDropdown(),
          const SizedBox(height: 16),
          
          // Alamat
          _buildTextField(
            controller: _addressController,
            label: 'Alamat',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Alamat harus diisi';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          const Row(
            children: [
              Icon(Icons.medical_information_outlined,
                  size: 20, color: Color(0xFF1A1A2E)),
              SizedBox(width: 8),
              Text(
                'Informasi Medis & Catatan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFEEEEEE)),
          
          // Health Condition (ganti dari medical_condition)
          _buildTextField(
            controller: _healthConditionController,
            label: 'Riwayat Kesehatan',
            icon: Icons.medical_information_outlined,
            maxLines: 3,
            hintText: 'Contoh: Hipertensi, Diabetes, Asma, dll',
          ),
          const SizedBox(height: 16),
          
          // Notes (TAMBAHAN)
          _buildTextField(
            controller: _notesController,
            label: 'Catatan Tambahan',
            icon: Icons.note_alt_outlined,
            maxLines: 3,
            hintText: 'Catatan penting lainnya...',
          ),
        ],
      ),
    );
  }

  // Dropdown untuk Gender
  Widget _buildGenderDropdown() {
  // Pastikan _selectedGender selalu valid
  String? validValue;
  if (_selectedGender != null && 
      ['Laki-laki', 'Perempuan', 'Lainnya'].contains(_selectedGender)) {
    validValue = _selectedGender;
  } else {
    validValue = null; // Reset ke null jika tidak valid
    // Opsional: set ke default value jika diperlukan
    // validValue = 'Laki-laki';
  }
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Jenis Kelamin',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonFormField<String>(
          initialValue: validValue, // Gunakan validValue yang sudah dipastikan
          hint: const Text('Pilih jenis kelamin'),
          isExpanded: true,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: Icon(Icons.people_outline, size: 20, color: Color(0xFF9CA3AF)),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Laki-laki',
              child: Text('Laki-laki'),
            ),
            DropdownMenuItem(
              value: 'Perempuan',
              child: Text('Perempuan'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGender = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Jenis kelamin harus dipilih';
            }
            return null;
          },
        ),
      ),
    ],
  );
}

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _healthConditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}