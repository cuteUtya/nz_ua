import 'package:adobe_spectrum/Components/navigation_bar_android.dart';
import 'package:design_system_provider/desing_components.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:adobe_spectrum/Components/Divider.dart' as adobe;

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
  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: design.layout.spacing200.horizontal,
          child: const adobe.Divider(
            dividerSize: DividerSize.medium,
          ),
        ),
        const NavigationBarAndroid(usePrimaryBackground: false, items: [
          NavigationBarItem(
            name: 'Home',
            icon: SpectrumIcons.smock_home,
          ),
          NavigationBarItem(
            name: 'Diary',
            icon: SpectrumIcons.smock_calendar,
          ),
          NavigationBarItem(
            name: 'Profile',
            icon: SpectrumIcons.smock_user,
          ),
          NavigationBarItem(
            name: 'News',
            icon: SpectrumIcons.smock_news,
          ),
          NavigationBarItem(
            name: 'Settings',
            icon: SpectrumIcons.smock_settings,
          ),
        ])
      ],
    );
  }
}
