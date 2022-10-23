import 'dart:convert';

import 'package:adobe_spectrum/spectrum_desing.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Components/Screens/AppMain.dart';
import 'package:nz_ua/Components/Screens/ForgotPasswordScreen.dart';
import 'package:nz_ua/Components/Screens/SignIn.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/nz_db.dart';
import 'package:nz_ua/nzsiteapi/types.dart';
import 'package:nz_ua/theme.dart';
import 'package:prefs/prefs.dart';
import 'package:design_system_provider/desing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ClientTheme.init();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      home: Material(
        child: Desing(
          desingSystem: Spectrum(theme: SpectrumTheme.dark),
          child: ColoredBox(
            color: NTheme.field('base.back'),
            child: FutureBuilder(
              builder: (_, __) => const MyApp(),
              future: NzDB().load(),
            ),
          ),
        ),
      ),
      theme: ThemeData(
        fontFamily: 'Adobe Clean',
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => MyAppState();
}

class MyAppState extends State {
  @override
  void initState() {
    super.initState();
    Prefs.init();
  }

  @override
  void dispose() {
    super.dispose();
    Prefs.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NzApi nzapi = NzApi(
      onLoad: (api) {},
    );

    var design = Desing.of(context);

    return Container(
      color: design.colors.gray.shade100,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          StreamBuilder(
            builder: (_, value) {
              var state = value.data;
              switch (state.runtimeType) {
                case NeedLoginState:
                  return SignInScreen(
                    state: state as NeedLoginState,
                    api: nzapi,
                  );
                case NeedEmailState:
                  return ForgotPasswordScreen(
                    nzApi: nzapi,
                  );
                case StateLogined:
                  return AppMain(
                    api: nzapi,
                  );
                  break;
              }
              return Container();
            },
            stream: nzapi.loginState,
          ),
          Opacity(
            opacity: 0.3,
            child: AbsorbPointer(child:  SizedBox(
              width: 1,
              height: 1,
              child: Visibility(
                visible: true,
                //visible: false,
                child: nzapi,
              ),
            ),),
          ),
        ],
      ),
    );
  }
}
