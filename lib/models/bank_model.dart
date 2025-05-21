import 'package:ukl_2025/services/url.dart' as url;

class BankModel {
  int? id;
  String? title;
  double? voteAverage;
  String? overview;
  String? posterPath;
  BankModel({
    required this.id,
    required this.title,
    this.voteAverage,
    this.overview,
    required this.posterPath,
  });
  BankModel.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    title = parsedJson["title"];
    voteAverage = double.parse(parsedJson["voteaverage"].toString());
    overview = parsedJson["overview"];
    posterPath = "${url.BaseUrl}/${parsedJson["posterpath"]}";
  }
}
