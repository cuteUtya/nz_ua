import 'package:flutter/material.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Main(),
    );
  }
}

class Main extends StatelessWidget {
  static WebViewController? _controller;
  static NzApi? _api;
  @override
  Widget build(BuildContext context) {
    return NzApi(onLoad: (api) {
      print('login call');
      api.login('name', 'pass');
    });
  }
}
