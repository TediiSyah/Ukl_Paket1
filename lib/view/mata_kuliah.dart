import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MatkulPage extends StatefulWidget {
  const MatkulPage({Key? key}) : super(key: key);

  @override
  State<MatkulPage> createState() => _MatkulPageState();
}

class _MatkulPageState extends State<MatkulPage> {
  List<Map<String, dynamic>> matkulList = [];
  Set<int> selectedIds = {};

  @override
  void initState() {
    super.initState();
    fetchMatkul();
  }

  Future<void> fetchMatkul() async {
    final response = await http.get(
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl1/api/getmatkul'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];

      print(data); // cek outputnya

      setState(() {
        matkulList = data.cast<Map<String, dynamic>>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil data mata kuliah'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> kirimMatkulTerpilih() async {
    final selectedMatkul = matkulList
        .where((matkul) =>
            selectedIds.contains(int.parse(matkul['id'].toString())))
        .map((matkul) => {
              'id': matkul['id'].toString(),
              'nama_matkul': matkul['nama_matkul'].toString(),
              'sks': int.parse(matkul['sks'].toString()),
            })
        .toList();

    print(
        'Data yang dikirim ke server: $selectedMatkul'); // PRINT data yg dikirim

    final response = await http.post(
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl1/api/selectmatkul'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'list_matkul': selectedMatkul}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // PRINT response server

    final result = jsonDecode(response.body);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result['status'] == true ? 'Sukses' : 'Gagal'),
        content: Text(result['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      color: Colors.red,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: const [
          Expanded(
              flex: 1,
              child: Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text("Mat Kul",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child:
                  Text("SKS", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Center(
                  child: Text("Pilih",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget buildMatkulRow(Map<String, dynamic> matkul) {
    int id = int.parse(matkul['id'].toString());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text(matkul['id'].toString())),
          Expanded(
              flex: 3,
              child: Text(matkul['nama_matkul']
                  .toString())), // Pastikan key-nya sesuai API
          Expanded(flex: 1, child: Text(matkul['sks'].toString())),
          Expanded(
            flex: 1,
            child: Checkbox(
              value: selectedIds.contains(id),
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedIds.add(id);
                  } else {
                    selectedIds.remove(id);
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Mata Kuliah"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: matkulList.length,
                itemBuilder: (context, index) {
                  return buildMatkulRow(matkulList[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedIds.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Peringatan"),
                      content:
                          const Text("Harap pilih minimal satu mata kuliah."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                } else {
                  kirimMatkulTerpilih();
                }
              },
              child: const Text(
                "Submit Matkul Terpilih",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
