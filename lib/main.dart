import 'package:flutter/material.dart';
import 'package:ukl_2025/models/matkul.dart';
import 'package:ukl_2025/services/profile_services.dart';
import 'package:ukl_2025/view/login_view.dart';
import 'package:ukl_2025/view/profile_view.dart';
import 'package:ukl_2025/view/register_view.dart';
import 'package:ukl_2025/view/mata_kuliah.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // routes: {
      //   '/#': (Context) => RegisterUserView(),
      // },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MatkulPage(),
    );
  }
}
