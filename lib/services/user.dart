import 'package:ukl_2025/models/respon_data_map.dart';
import 'package:ukl_2025/models/user_login.dart';
import 'package:ukl_2025/services/url.dart' as url;
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  Future registerUser(data) async {
    var uri = Uri.parse(url.BaseUrl + '/register');
    var register = await http.post(uri, body: data);

    if (register.statusCode == 200) {
      var data = json.decode(register.body);
      if (data["status"] == true) {
        ResponseDataMap response = ResponseDataMap(
            status: true, message: "Sukses menambah user", data: data);
        return response;
      } else {
        var message = '';
        for (String key in data["message"].keys) {
          message += data["message"][key][0].toString() + '\n';
        }
        ResponseDataMap response =
            ResponseDataMap(status: false, message: message);
        return response;
      }
    } else {
      ResponseDataMap response = ResponseDataMap(
          status: false,
          message:
              "gagal menambah user dengan code error ${register.statusCode}");
      return response;
    }
  }

  Future<ResponseDataMap> loginUser(Map<String, String> data) async {
    var uri = Uri.parse(url.BaseUrl + "/login");
    var register = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (register.statusCode == 200) {
      var responseData = json.decode(register.body);

      // Pastikan 'data' ada dalam response
      if (!responseData.containsKey("data") || responseData["data"] == null) {
        print("Error: 'data' tidak ditemukan dalam response!");
        return ResponseDataMap(
            status: false, message: "Gagal login, data user tidak ditemukan");
      }

      UserLogin userLogin = UserLogin(
          status: responseData["status"],
          message: responseData["message"],
          username: responseData["data"]["username"],
          password: responseData["data"]["password"]);

      await userLogin.prefs();
      return ResponseDataMap(
          status: true, message: "Sukses login user", data: responseData);
    } else {
      return ResponseDataMap(
          status: false,
          message: "Gagal login user dengan error code ${register.statusCode}");
    }
  }

  Future<ResponseDataMap> updateUser(Map<String, String> data) async {
    var uri = Uri.parse(url.BaseUrl + "/update");
    var register = await http.post(uri,
        body: jsonEncode(data), headers: {"Content-Type": "application/json"});
    if (register.statusCode == 200) {
      var responseData = json.decode(register.body);
      return ResponseDataMap(
          status: true, message: "Sukses update user", data: responseData);
    } else {
      return ResponseDataMap(
          status: false,
          message:
              "Gagal update user dengan error code ${register.statusCode}");
    }
  }
}
