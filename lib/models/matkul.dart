class Matkul {
  final int id;
  final String namaMatkul;
  final int sks;

  Matkul({
    required this.id,
    required this.namaMatkul,
    required this.sks,
  });

  factory Matkul.fromJson(Map<String, dynamic> json) {
    return Matkul(
      id: int.parse(json['id'].toString()),
      namaMatkul: json['nama_matkul'].toString(),
      sks: int.parse(json['sks'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'nama_matkul': namaMatkul,
      'sks': sks,
    };
  }
}
