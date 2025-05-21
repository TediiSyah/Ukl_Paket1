import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/matkul.dart';

class MatkulService {
  final String baseUrl = 'https://learn.smktelkom-mlg.sch.id/ukl1/api';

  Future<List<Matkul>> fetchMatkul() async {
    final response = await http.get(Uri.parse('$baseUrl/getmatkul'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => Matkul.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data mata kuliah');
    }
  }

  Future<Map<String, dynamic>> kirimMatkulTerpilih(
      List<Matkul> selectedMatkul) async {
    final response = await http.post(
      Uri.parse('$baseUrl/selectmatkul'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'list_matkul': selectedMatkul.map((e) => e.toJson()).toList()}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengirim data mata kuliah');
    }
  }
}
