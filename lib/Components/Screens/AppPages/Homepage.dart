import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/MarkDisplay.dart';
import 'package:nz_ua/Components/db_loader_wrapper.dart';
import 'package:nz_ua/Components/localization.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';

class Homepage extends StatelessWidget {
  const Homepage({
    Key? key,
    required this.api,
  }) : super(key: key);

  final NzApi api;
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

    return DatabaseLoaderWrapper<SideMetadata>(
      parseCallback: SideMetadata.fromJson,
      id: 1,
      onBuild: (value) => StreamBuilder(
        stream: api.sideMetadata,
        builder: (_, data) {
          SideMetadata? metadata = data.data ?? (value as SideMetadata?);

          if (data.data == null) {
            api.forceUpdateMetadata();
          }

          if (metadata == null) {
            return Container();
          }

          //save new value to db
          if (data.data != null) {
            metadata.deleteAllValues().then(
                  (value) => metadata.save(),
                );
          }
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
                                size: design.typography.fontSize100.value,
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
    );
  }
}
