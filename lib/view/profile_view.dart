import 'package:flutter/material.dart';
import 'package:ukl_2025/services/profile_services.dart';

class UpdateProfileView extends StatefulWidget {
  const UpdateProfileView({super.key});

  @override
  State<UpdateProfileView> createState() => _UpdateProfileViewState();
}

class _UpdateProfileViewState extends State<UpdateProfileView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nama = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _telepon = TextEditingController();
  String? _gender;
  int? _idPelanggan;
  bool _loading = false;

  Future<void> getProfile() async {
    try {
      final jsonResponse = await ProfileService.getProfile();

      if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        setState(() {
          _idPelanggan = int.tryParse(data['id'].toString());
          _nama.text = data['nama_pelanggan'] ?? '';
          _alamat.text = data['alamat'] ?? '';
          _gender = data['gender'] ?? 'Laki-laki';
          _telepon.text = data['telepon'] ?? '';
        });
      } else {
        _showError(jsonResponse['message'] ?? "Data profil tidak ditemukan");
      }
    } catch (e) {
      _showError("Terjadi kesalahan: $e");
    }
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_idPelanggan == null) {
      _showError("ID pelanggan tidak ditemukan");
      return;
    }

    setState(() => _loading = true);

    try {
      final jsonResponse = await ProfileService.updateProfile(
        id: _idPelanggan!,
        nama: _nama.text.trim(),
        alamat: _alamat.text.trim(),
        gender: _gender ?? '',
        telepon: _telepon.text.trim(),
      );

      final bool success = jsonResponse['status'] == true;
      final String message = jsonResponse['message'] ?? "Tidak ada pesan";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      _showError("Gagal mengupdate profil: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  @override
  void dispose() {
    _nama.dispose();
    _alamat.dispose();
    _telepon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Update Profil'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informasi Pengguna",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nama,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Nama wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _alamat,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Alamat wajib diisi'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _gender,
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
                        onChanged: (value) => setState(() => _gender = value),
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null ? 'Pilih gender' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telepon,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Telepon',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Telepon wajib diisi';
                          }
                          if (!RegExp(r'^[0-9]{8,15}$')
                              .hasMatch(value.trim())) {
                            return 'Nomor telepon tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: updateProfile,
                          label: const Text('Simpan Perubahan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
