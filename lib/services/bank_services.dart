import 'dart:convert';
import 'package:ukl_2025/models/bank_model.dart';
import 'package:ukl_2025/models/respon_data_list.dart';
// import 'package:ukl_2025/models/respon_data_map.dart';
// import 'package:ukl_2025/models/user_login.dart';
import 'package:ukl_2025/services/url.dart' as url;
import 'package:http/http.dart' as http;
import 'package:ukl_2025/models/user_login.dart';

class BankServices {
  Future getMovie() async {
    UserLogin userLogin = UserLogin();
    var user = await userLogin.getUserLogin();
    if (user.status == false) {
      ResponseDataList response = ResponseDataList(
          status: false, message: 'anda belum login / token invalid');
      return response;
    }
    var uri = Uri.parse(url.BaseUrl + '/register');
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
    };
    var getMovie = await http.get(uri, headers: headers);

    if (getMovie.statusCode == 200) {
      var data = json.decode(getMovie.body);
      if (data["status"] == true) {
        List movie = data["data"].map((r) => BankModel.fromJson(r)).toList();
        ResponseDataList response = ResponseDataList(
            status: true, message: 'success load data', data: movie);
        return response;
      } else {
        ResponseDataList response =
            ResponseDataList(status: false, message: 'Failed load data');
        return response;
      }
    } else {
      ResponseDataList response = ResponseDataList(
          status: false,
          message: "gagal load movie dengan code error ${getMovie.statusCode}");
      return response;
    }
  }
}
