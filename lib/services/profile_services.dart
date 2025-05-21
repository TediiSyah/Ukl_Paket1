import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  static const String _baseUrl = 'https://learn.smktelkom-mlg.sch.id/ukl1/api';

  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$_baseUrl/profil');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Gagal memuat profil (status: ${response.statusCode})");
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int id,
    required String nama,
    required String alamat,
    required String gender,
    required String telepon,
  }) async {
    final url = Uri.parse('$_baseUrl/update/$id');

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
      },
      body: {
        'nama_pelanggan': nama,
        'alamat': alamat,
        'gender': gender,
        'telepon': telepon,
      },
    );

    return json.decode(response.body);
  }
}
