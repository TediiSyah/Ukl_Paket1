import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status = false;
  String? message;
  String? username;
  String? password;
  UserLogin({
    this.status,
    this.message,
    this.username,
    this.password,
  });

  Future prefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("status", status!);
    prefs.setString("message", message!);
    prefs.setString("username", username!);
    prefs.setString("password", password!);
  }

  Future getUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserLogin userLogin = UserLogin(
      status: prefs.getBool("status")!,
      message: prefs.getString("message")!,
      username: prefs.getString("username")!,
      password: prefs.getString("password")!,
    );
    return userLogin;
  }
}
