import 'dart:async';

import 'package:adobe_spectrum/spectrum_desing.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/TextWithIcon.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/ISQLObject.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';

import '../../Components/MarkDisplay.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({
    Key? key,
    required this.api,
    required this.contentScroll,
  }) : super(key: key);
  final NzApi api;
  final ScrollController contentScroll;
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
    // drop table
    // DiaryContentTopDownDbObject(content: []).deleteAllValues();
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
    if (content.isNotEmpty) {
      var db = DiaryContentTopDownDbObject(content: content);
      db.deleteAllValues().then((_) => {db.save()});
    }
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

  final List<GlobalKey> _keys = [];
  int today = 0;
  bool init = false;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!init && _keys.isNotEmpty) {
          var padding = design.layout.spacing300.top.vertical;
          double position = padding;
          init = true;

          for (var c = 0; c < today; c++) {
            position += _keys[c].currentContext!.size!.height;
            position += padding * 2;
          }

          widget.contentScroll.animateTo(
            position,
            duration: const Duration(seconds: 1),
            curve: Curves.bounceIn,
          );
        }
      },
    );

    if (content.isEmpty) return Container();
    var curr = content.last;

    List<Widget> buildTableLine(DiaryLine line) {
      var time = Container(
        width: 60,
        alignment: Alignment.center,
        child: Text.rich(
          design.typography.text(
            '${line.lessonTime.fromTime ?? ''}\n${line.lessonTime.toTime ?? ''}',
            size: design.typography.fontSize100.value,
          ),
        ),
      );

      Widget buildHomework(Homework s) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: design.layout.spacing100.top
                  .add(design.layout.spacing100.bottom),
              child: Dash(
                dashColor: design.colors.gray.shade300,
                dashGap: 8,
                dashLength: 8,
                //TODO - 50? Also bruh
                length: MediaQuery.of(context).size.width * 0.85 - 50,
              ),
            ),
            Text.rich(
              design.typography.text(
                s.exercises?.first.exercise ?? '',
                size: design.typography.fontSize75.value,
              ),
            )
          ],
        );
      }

      Widget buildContent(DiaryLineContent content) {
        Widget r = Padding(
          padding: design.layout.spacing100.all,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                design.typography.text(
                  content.name ?? '',
                  size: design.typography.fontSize100.value,
                  semantic: TextSemantic.heading,
                ),
              ),
              if ((content.classAudience ?? '') != '')
                TextWithIcon(
                  text: content.classAudience!,
                  icon: SpectrumIcons.smock_locationbaseddate,
                ),
              if ((content.topic ?? '') != '')
                TextWithIcon(
                  text: content.topic ?? '',
                  icon: SpectrumIcons.smock_tasklist,
                ),
              for (Homework hm in (content.homework ?? []))
                if (hm.exercises?.isNotEmpty ?? false)
                  if ((hm.exercises![0].exercise ?? '') != '') buildHomework(hm)
            ],
          ),
        );

        var markInt = int.tryParse(content.mark.toString());

        if (markInt != null) {
          r = Stack(
            children: [
              r,
              Positioned(
                right: design.layout.spacing200.right.horizontal,
                top: design.layout.spacing200.top.vertical,
                child: MarkDisplay(
                  mark: markInt,
                ),
              )
            ],
          );
        }

        return r;
      }

      Widget content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c in line.content ?? []) buildContent(c),
        ],
      );

      return [
        time,
        content,
      ];
    }

    List<Widget> items = [];

    if (curr.content != null) {
      for (var item in curr.content!) {
        _keys.add(GlobalKey());
        bool today = isToday(item.dayDate);
        if (today) {
          this.today = curr.content!.indexOf(item);
        }
        items.add(
          Padding(
            padding: design.layout.spacing300.top,
            child: InformationTable(
              key: _keys.last,
              title: item.dayDate ?? "bruh",
              columnsSize: const [0.15, 0.85],
              content: [
                if (item.lines != null)
                  for (var line in item.lines!) buildTableLine(line)
              ],
              topBarColor: today
                  ? design.colors.blue.shade600
                  : design.colors.gray.shade400,
            ),
          ),
        );
      }
    }

    return Column(
      children: <Widget>[
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
          ] +
          items,
    );
  }
}
