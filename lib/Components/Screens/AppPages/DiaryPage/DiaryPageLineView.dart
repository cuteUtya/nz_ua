import 'dart:async';

import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/MarkDisplay.dart';
import 'package:nz_ua/Components/Components/TextWithIcon.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/ISQLObject.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';
import 'package:rxdart/rxdart.dart';

class DiaryPageLineView extends StatefulWidget {
  const DiaryPageLineView({
    Key? key,
    required this.api,
    required this.currentFromDate,
    required this.intervalStream,
  }) : super(key: key);
  final NzApi api;
  final String currentFromDate;
  final BehaviorSubject<DateTimeInterval> intervalStream;
  @override
  State<StatefulWidget> createState() => DiaryPageLineViewState();
}

class DiaryPageLineViewState extends State<DiaryPageLineView> {
  List<DiaryContentTopToDown> content = [];
  bool receiveNewValues = false;
  StreamSubscription? streamSubscription;
  int todayIndex = 0;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    var current = tryFindMatchContent(widget.currentFromDate);

    if (current?.content == null) {
      widget.api.forceUpdateDiary(fromDate: widget.currentFromDate);
      //TODO load screen
      return Container();
    }

    if(current!.interval != null) widget.intervalStream.add(current!.interval!);

    List<Widget> items = [];

    for (var item in current!.content!) {
      if (item != null) {
        bool today = isToday(item.dayDate);
        if (today) {
          todayIndex = current!.content!.indexOf(item);
        }
        items.add(
          Padding(
            padding: design.layout.spacing300.top,
            child: InformationTable(
              key: UniqueKey(),
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

    return Column(children: items);
  }

  List<Widget> buildTableLine(DiaryLine line) {
    var design = Desing.of(context);
    var time = Container(
      width: 60,
      alignment: Alignment.center,
      margin: design.layout.spacing100.vertical,
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

    return [time, content];
  }

  @override
  void initState() {
    loadValuesFromDB();
    listenNewValues();
    super.initState();
  }

  void listenNewValues() {
    streamSubscription = widget.api.diaryContentTopDown.listen(
      (event) {
        receiveNewValues = true;
        setState(() => content.add(event));
      },
    );
  }

  void loadValuesFromDB() async {
    // drop table
    // DiaryContentTopDownDbObject(content: []).deleteAllValues();
    var c = await ISQLObject.getById<DiaryContentTopDownDbObject>(1);
    print(c);
    //  try {
    if (c != null) {
      var d = DiaryContentTopDownDbObject.fromJson(c).content;
      if (d != null) setState(() => content = d);
    }
    /*  } catch (e) {
      //TODO fix null's while parsing
    }*/
  }

  bool isToday(String? s) {
    if (s == null) return false;
    bool r = s.contains('сьогодні') || s.contains('сегодня');
    return r;
  }

  @override
  void dispose() {
    if (content.isNotEmpty && receiveNewValues) {
      var db = DiaryContentTopDownDbObject(content: content);
      ISQLObject.dropTableByName(ISQLObject.getNameOfChildDB(
          ISQLObject.getNameOfDB(type: DiaryContentTopToDown)));
      db.save(id: 1);
    }
    streamSubscription?.cancel();
    super.dispose();
  }

  DiaryContentTopToDown? tryFindMatchContent(String dateString) {
    var date = DateTime.parse(dateString);

    DiaryContentTopToDown? r;

    for (var element in content) {
      if ((element.interval?.fromTime ?? '') != '' &&
          (element.interval?.toTime ?? '') != '') {
        if (DateTime.parse(element.interval!.fromTime!).isBefore(date) &&
            DateTime.parse(element.interval!.toTime!).isAfter(date)) {
          r = element;
        }
      }
    }

    return r;
  }
}
