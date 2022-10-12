import 'package:flutter/material.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';
import 'package:nz_ua/theme.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClientTheme.init();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      home: ColoredBox(
        color: NTheme.field('base.back'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    NzApi nzapi = NzApi(
      onLoad: (api) {},
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        nzapi,
        MaterialButton(
          onPressed: () async {
            await nzapi.goto('/dashboard/news');
          },
          color: Colors.blue,
        ),
      ],
    );
  }
}
