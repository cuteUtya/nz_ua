import 'package:adobe_spectrum/Components/navigation_bar_android.dart';
import 'package:design_system_provider/desing_components.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/MarkDisplay.dart';
import 'package:nz_ua/Components/Screens/AppPages/Homepage.dart';
import 'package:nz_ua/Components/db_loader_wrapper.dart';
import 'package:nz_ua/Components/localization.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:adobe_spectrum/Components/Divider.dart' as adobe;

import '../../nzsiteapi/types.dart';

class AppMain extends StatefulWidget {
  const AppMain({
    Key? key,
    required this.api,
  }) : super(key: key);
  final NzApi api;
  @override
  State<StatefulWidget> createState() => _AppMainState();
}

class _AppMainState extends State<AppMain> {
  late String state = HOME;

  late List<NavigationBarItem> navigation = [
    NavigationBarItem(
      name: appLocalization.home,
      icon: SpectrumIcons.smock_home,
      onClick: () => goto(HOME),
    ),
    NavigationBarItem(
      name: appLocalization.diary,
      icon: SpectrumIcons.smock_calendar,
      onClick: () => goto(DIARY),
    ),
    NavigationBarItem(
      name: appLocalization.profile,
      icon: SpectrumIcons.smock_user,
      onClick: () => goto(PROFILE),
    ),
    NavigationBarItem(
      name: appLocalization.news,
      icon: SpectrumIcons.smock_news,
      onClick: () => goto(NEWS),
    ),
    NavigationBarItem(
      name: appLocalization.settings,
      icon: SpectrumIcons.smock_settings,
      onClick: () => goto(SETTINGS),
    )
  ];

  String HOME = "HOME";
  String DIARY = "DIARY";
  String PROFILE = "PROFILE";
  String NEWS = "NEWS";
  String SETTINGS = "SETTINGS";

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    //todo show error that no internet

    Widget page = Container();

    if (state == HOME) {
      page = Homepage(api: widget.api);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ListView(
            padding: design.layout.spacing300.vertical,
            children: [
              Padding(
                padding: design.layout.spacing300.horizontal,
                child: page,
              ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: design.layout.spacing200.horizontal,
              child: const adobe.Divider(
                dividerSize: DividerSize.medium,
              ),
            ),
            NavigationBarAndroid(
              usePrimaryBackground: false,
              items: navigation,
            )
          ],
        ),
      ],
    );
  }

  void goto(String state) {
    setState(() => this.state = state);
  }
}
