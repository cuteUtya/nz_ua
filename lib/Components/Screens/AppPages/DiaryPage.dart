import 'dart:async';

import 'package:adobe_spectrum/spectrum_desing.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/ISQLObject.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({
    Key? key,
    required this.api,
  }) : super(key: key);
  final NzApi api;
  @override
  State<StatefulWidget> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DiaryContentTopDownDbObject? data;
  List<DiaryContentTopToDown> content = [];

  @override
  void initState() {
    load();
    super.initState();
  }

  StreamSubscription? streamSubscription;

  void load() async {
    var c = await ISQLObject.getById<DiaryContentTopDownDbObject>(1);
    if (c != null) {
      var d = DiaryContentTopDownDbObject.fromJson(c).content;
      if (d != null) setState(() => content = d);
    }

    streamSubscription = widget.api.diaryContentTopDown.listen((event) {
      setState(() => content.add(event));
    });

    widget.api.forceUpdateDiary();
  }

  @override
  void dispose() {
    var db = DiaryContentTopDownDbObject(content: content);
    db.deleteAllValues().then((_) => {
      db.save()
    });
    streamSubscription?.cancel();
    super.dispose();
  }

  void next() {
    print('next');
  }

  void previus() {
    print('previus');
  }

  bool isToday(String? s) {
    if (s == null) return false;
    return s.contains('сьогодні') ||
        s.contains(DateTime.now().day.toString()) ||
        s.contains('сегодня');
  }

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    if (content.isEmpty) return Container();
    var curr = content[0];

    List<Widget> buildTableLine(DiaryLine line) {
      return [
        Container(
          width: 60,
          color: Colors.white,
          alignment: Alignment.center,
          child: Text.rich(
            design.typography.text(
              '${line.lessonTime.fromTime}\n${line.lessonTime.toTime}',
              size: design.typography.fontSize100.value,
            ),
          ),
        )
      ];
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => previus(),
              child: Icon(
                SpectrumIcons.smock_chevronleft,
                color: design.colors.gray.shade900,
              ),
            ),
            Text.rich(
              design.typography.text(
                '${curr.interval?.fromTime} — ${curr.interval?.toTime}',
                size: design.typography.fontSize200.value,
                semantic: TextSemantic.detail,
              ),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: () => next(),
              child: Icon(
                SpectrumIcons.smock_chevronright,
                color: design.colors.gray.shade900,
              ),
            )
          ],
        ),
        if (curr.content != null)
          for (var item in curr.content!)
            Padding(
              padding: design.layout.spacing300.top,
              child: InformationTable(
                title: item.dayDate ?? "bruh",
                content: [
                  if (item.lines != null)
                    for (var line in item.lines!) buildTableLine(line)
                ],
                topBarColor: isToday(item.dayDate)
                    ? design.colors.blue.shade600
                    : design.colors.gray.shade400,
              ),
            ),
      ],
    );
    /*return FutureBuilder(
      builder: (_, dbValueData) {
        DiaryContentTopDownDbObject? dbValue;
        if (dbValueData.data != null) {
          dbValue = DiaryContentTopDownDbObject.fromJson(dbValueData.data!);
        }
        return StreamBuilder(
          stream: widget.api.diaryContentTopDown,
          builder: (_, actualValueData) {
            DiaryContentTopToDown? actualValue;
            if (dbValue != null) {
              //TODO get value that match date, not first
              actualValue ??= dbValue.content[0];
            }

            if (actualValueData.data != null) {
              actualValue = actualValueData.data;
            }

            if (actualValue == null) {
              widget.api.forceUpdateDiary();
              return Container();
            }

            actualValue.save();

            return Column();
          },
        );
      },
      future: ,
    );*/
  }
}
