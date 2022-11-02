import 'dart:async';

import 'package:adobe_spectrum/spectrum_desing.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
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
  List<DiaryContentTopToDown> content = [];
  StreamSubscription? streamSubscription;
  late DateTime currentFromDate = DateTime.now();
  final List<GlobalKey> _keys = [];
  int todayIndex = 0;
  bool inited = false;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!inited && _keys.isNotEmpty) {
          inited = true;
          scrollToToday();
        }
      },
    );

    var current = tryFindMatchContent(formatDate(currentFromDate));

    if (current?.content == null) {
      print('no selected content, load');
      widget.api.forceUpdateDiary(fromDate: formatDate(currentFromDate));
      //TODO load screen
      return Container();
    }

    List<Widget> items = [];

    _keys.clear();
    for (var item in current!.content!) {
      if (item != null) {
        _keys.add(GlobalKey());
        bool today = isToday(item.dayDate);
        if (today) {
          todayIndex = current!.content!.indexOf(item);
        }
        items.add(
          Padding(
            key: _keys.last,
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

    print(current?.interval?.fromTime);

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
                    '${current!.interval?.fromTime} — ${current!.interval?.toTime}',
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

  String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

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

  void scrollToToday() {
    var design = Desing.of(context);
    var padding = design.layout.spacing300.top.vertical;
    double position = padding;

    for (var c = 0; c < todayIndex; c++) {
      position += _keys[c].currentContext!.size!.height;
      position += padding;
    }

    widget.contentScroll.animateTo(
      position,
      duration: const Duration(seconds: 1),
      curve: Curves.bounceIn,
    );
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
        setState(() => content.add(event));
      },
    );
  }

  void loadValuesFromDB() async {
    // drop table
    // DiaryContentTopDownDbObject(content: []).deleteAllValues();
    var c = await ISQLObject.getById<DiaryContentTopDownDbObject>(1);
    try {
      if (c != null) {
        var d = DiaryContentTopDownDbObject.fromJson(c).content;
        if (d != null) setState(() => content = d);
      }
    } catch (e) {
      //TODO fix null's while parsing
    }
  }

  @override
  void dispose() {
    if (content.isNotEmpty) {
      var db = DiaryContentTopDownDbObject(content: content);
      ISQLObject.dropTableByName(ISQLObject.getNameOfChildDB(ISQLObject.getNameOfDB(type: DiaryContentTopToDown)));
      db.deleteAllValues().then((_) => {db.save()});
    }
    streamSubscription?.cancel();
    super.dispose();
  }

  Duration week = const Duration(days: 7);

  void next() {
    setState(() => currentFromDate = currentFromDate.add(week));
  }

  void previus() {
    setState(() => currentFromDate = currentFromDate.subtract(week));
  }

  bool isToday(String? s) {
    if (s == null) return false;
    bool r = s.contains('сьогодні') || s.contains('сегодня');
    return r;
  }
}
