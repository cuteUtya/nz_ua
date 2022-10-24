import 'package:adobe_spectrum/Components/navigation_bar_android.dart';
import 'package:design_system_provider/desing_components.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/MarkDisplay.dart';
import 'package:nz_ua/Components/localization.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:adobe_spectrum/Components/Divider.dart' as adobe;

import '../../nzsiteapi/types.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    Widget buildMarkLine(Mark mark) {
      return Padding(
        padding: design.layout.spacing100.left
            .add(design.layout.spacing100.vertical)
            .add(design.layout.spacing200.right),
        child: Row(
          children: [
            Text.rich(
              design.typography.text(
                (mark.lesson ?? '').toString(),
                size: design.typography.fontSize100.value,
              ),
            ),
            const Spacer(),
            MarkDisplay(mark: mark.value)
          ],
        ),
      );
    }

    Widget buildBirthdayLine(Birthday bday) {
      //todo open profile onClick
      return Padding(
        padding: design.layout.spacing100.all,
        child: Text.rich(
          TextSpan(
            children: [
              design.typography.text(
                '${bday.user?.fullName ?? ''}\n',
                size: design.typography.fontSize100.value,
                semantic: TextSemantic.heading,
              ),
              design.typography.text(
                bday.date ?? '',
                size: design.typography.fontSize100.value,
              )
            ],
          ),
        ),
      );
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
                child: StreamBuilder(
                  stream: widget.api.sideMetadata,
                  builder: (_, data) {
                    if (data.data == null) {
                      widget.api.forceUpdateMetadata();
                      return Container();
                    }
                    var metadata = data.data!;
                    var padding = Padding(
                      padding: design.layout.spacing300.top,
                      child: Container(),
                    );
                    return Column(
                      children: [
                        InformationTable(
                          title: appLocalization.tomorrow_homework,
                          content: (metadata.comingHomework?.length ?? 0) == 0
                              ? [
                                  [
                                    Padding(
                                      padding: design.layout.spacing200.all,
                                      child: Text.rich(
                                        design.typography.text(
                                          appLocalization.no_homework_tomorrow,
                                          size: design
                                              .typography.fontSize100.value,
                                        ),
                                      ),
                                    ),
                                  ]
                                ]
                              : [],
                          topBarColor: design.colors.green.shade600,
                        ),
                        padding,
                        InformationTable(
                          title: appLocalization.latest_mark,
                          content: (metadata.latestMarks ?? [])
                              .map((e) => [buildMarkLine(e)])
                              .toList(),
                          topBarColor: design.colors.blue.shade600,
                        ),
                        padding,
                        InformationTable(
                          title: appLocalization.coming_birthdays,
                          itemsAlign: Alignment.centerLeft,
                          topBarColor: design.colors.magenta.shade600,
                          content: (metadata.closestBirthdays ?? [])
                              .map((e) => [buildBirthdayLine(e)])
                              .toList(),
                        )
                      ],
                    );
                  },
                ),
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
            NavigationBarAndroid(usePrimaryBackground: false, items: [
              NavigationBarItem(
                name: appLocalization.home,
                icon: SpectrumIcons.smock_home,
              ),
              NavigationBarItem(
                name: appLocalization.diary,
                icon: SpectrumIcons.smock_calendar,
              ),
              NavigationBarItem(
                name: appLocalization.profile,
                icon: SpectrumIcons.smock_user,
              ),
              NavigationBarItem(
                name: appLocalization.news,
                icon: SpectrumIcons.smock_news,
              ),
              NavigationBarItem(
                name: appLocalization.settings,
                icon: SpectrumIcons.smock_settings,
              ),
            ])
          ],
        ),
      ],
    );
  }
}
