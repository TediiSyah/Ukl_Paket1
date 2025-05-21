import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ukl_2025/services/url.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nama = TextEditingController();
  final TextEditingController gender = TextEditingController();
  final TextEditingController alamat = TextEditingController();
  final TextEditingController telepon = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  File? _imageFile;
  Uint8List? _webImageBytes;
  String? _fileName;

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        if (kIsWeb) {
          _webImageBytes = file.bytes;
          _imageFile = null;
        } else {
          _imageFile = File(file.path!);
          _webImageBytes = null;
        }
        _fileName = file.name;
      });
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && _webImageBytes != null) {
      return Image.memory(_webImageBytes!, fit: BoxFit.cover);
    } else if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    }
    return const Center(child: Text("Tap untuk memilih foto"));
  }

  Future<void> _submit() async {
    if (_imageFile == null && _webImageBytes == null) {
      _showAlert('Foto harus dipilih');
      return;
    }

    if (!formKey.currentState!.validate()) {
      _showAlert('Semua field harus diisi dengan benar.');
      return;
    }

    final data = {
      "nama_nasabah": nama.text,
      "gender": gender.text,
      "alamat": alamat.text,
      "telepon": telepon.text,
      "username": username.text,
      "password": password.text,
    };

    try {
      final result = await registerUser(
        data,
        imageFile: _imageFile,
        webImageBytes: _webImageBytes,
        fileName: _fileName,
      );

      if (result['success']) {
        _showAlert('Registrasi berhasil: ${result['data']['message']}',
            isSuccess: true);
        _clearForm();
      } else {
        final errorMsg =
            result['error']['message'] ?? 'Terjadi kesalahan saat mendaftar.';
        _showAlert('Gagal: $errorMsg');
      }
    } catch (e) {
      _showAlert('Terjadi error: $e');
    }
  }

  Future<Map<String, dynamic>> registerUser(
    Map<String, String> data, {
    File? imageFile,
    Uint8List? webImageBytes,
    String? fileName,
  }) async {
    var uri = Uri.parse(BaseUrl + '/register');
    var request = http.MultipartRequest('POST', uri);

    data.forEach((key, value) {
      request.fields[key] = value;
    });

    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('foto', imageFile.path));
    } else if (webImageBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('foto', webImageBytes,
          filename: fileName ?? 'upload.jpg'));
    }

    var response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': jsonDecode(responseBody),
      };
    } else {
      return {
        'success': false,
        'error': jsonDecode(responseBody),
      };
    }
  }

  void _clearForm() {
    nama.clear();
    gender.clear();
    alamat.clear();
    telepon.clear();
    username.clear();
    password.clear();
    setState(() {
      _imageFile = null;
      _webImageBytes = null;
      _fileName = null;
    });
  }

  void _showAlert(String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isSuccess ? 'Sukses' : 'Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register User")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              _buildTextField(nama, 'Nama', 'Nama harus diisi'),
              _buildTextField(gender, 'Gender', 'Gender harus diisi'),
              _buildTextField(alamat, 'Alamat', 'Alamat harus diisi'),
              _buildTextField(telepon, 'Telepon', 'Telepon harus diisi'),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child:
                    Text('Foto', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildImagePreview(),
                ),
              ),
              if (_imageFile == null && _webImageBytes == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Pilih Foto',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 16),
              _buildTextField(username, 'Username', 'Username harus diisi'),
              _buildTextField(password, 'Password', 'Password harus diisi',
                  isPassword: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C81C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String validationMsg, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? validationMsg : null,
      ),
    );
  }
}
