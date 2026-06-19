import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddElderlyPage extends StatefulWidget {
  const AddElderlyPage({super.key});

  @override
  State<AddElderlyPage> createState() => _AddElderlyPageState();
}

class _AddElderlyPageState extends State<AddElderlyPage> {
  static const String _baseUrl = 'http://localhost:3000';

  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _healthConditionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _healthConditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_fullNameController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Nama lengkap tidak boleh kosong.');
      return false;
    }
    if (_ageController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Usia tidak boleh kosong.');
      return false;
    }
    if (_selectedGender == null) {
      setState(() => _errorMessage = 'Jenis kelamin harus dipilih.');
      return false;
    }
    if (_addressController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Alamat tidak boleh kosong.');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);

    if (!_validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (mounted) Navigator.pushReplacementNamed(context, '/');
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/elderly'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'full_name': _fullNameController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'gender': _selectedGender,
          'address': _addressController.text.trim(),
          'health_condition': _healthConditionController.text.trim(),
          'notes': _notesController.text.trim(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data lansia berhasil ditambahkan'),
              backgroundColor: Color(0xFF1A1A2E),
            ),
          );
          Navigator.pop(context, true); // kirim true → home_page refresh
        }
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _errorMessage = data['message'] ?? 'Gagal menyimpan data.';
        });
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'Tambah Lansia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Color(0xFFDC2626), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFFDC2626)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Nama Lengkap
            _buildLabel('Nama Lengkap *'),
            _buildTextField(
              controller: _fullNameController,
              hint: 'Masukkan nama lengkap',
              inputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),

            // Usia
            _buildLabel('Usia *'),
            _buildTextField(
              controller: _ageController,
              hint: 'Contoh: 75',
              inputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 18),

            // Jenis Kelamin
            _buildLabel('Jenis Kelamin *'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  hint: const Text(
                    'Pilih jenis kelamin',
                    style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF9CA3AF)),
                  items: _genderOptions
                      .map((g) => DropdownMenuItem(
                            value: g,
                            child: Text(g,
                                style: const TextStyle(
                                    fontSize: 14, color: Color(0xFF1A1A2E))),
                          ))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedGender = value),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Alamat
            _buildLabel('Alamat *'),
            _buildTextField(
              controller: _addressController,
              hint: 'Masukkan alamat lengkap',
              inputAction: TextInputAction.next,
              maxLines: 3,
            ),
            const SizedBox(height: 18),

            // Kondisi Kesehatan
            _buildLabel('Kondisi Kesehatan'),
            _buildTextField(
              controller: _healthConditionController,
              hint: 'Contoh: Hipertensi, Diabetes',
              inputAction: TextInputAction.next,
              maxLines: 2,
            ),
            const SizedBox(height: 18),

            // Catatan
            _buildLabel('Catatan'),
            _buildTextField(
              controller: _notesController,
              hint: 'Catatan tambahan (opsional)',
              inputAction: TextInputAction.done,
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 25, 153, 199),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF6B7280),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputAction inputAction = TextInputAction.next,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      textInputAction: inputAction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
        ),
      ),
    );
  }
}