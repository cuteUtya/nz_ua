import 'dart:async';

import 'package:adobe_spectrum/Components/action_group.dart';
import 'package:adobe_spectrum/spectrum_desing.dart';
import 'package:design_system_provider/desing_components.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:intl/intl.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/TextWithIcon.dart';
import 'package:nz_ua/Components/Screens/AppPages/DiaryPage/DiaryPageGridView.dart';
import 'package:nz_ua/Components/Screens/AppPages/DiaryPage/DiaryPageLineView.dart';
import 'package:nz_ua/Icons/spectrum_icons_icons.dart';
import 'package:nz_ua/nzsiteapi/ISQLObject.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';
import 'package:rxdart/rxdart.dart';

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
  late DateTime currentFromDate = DateTime.now();
  BehaviorSubject<DateTimeInterval> intervalSubject =
      BehaviorSubject<DateTimeInterval>();

  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    print(currentFromDate);

    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                StreamBuilder(
                  stream: intervalSubject.stream,
                  builder: (_, d) {
                    if(d.data != null) {
                      currentFromDate = DateTime.parse(d.data!.fromTime!);
                    }
                    return Text.rich(
                      design.typography.text(
                        '${d.data?.fromTime} — ${d.data?.toTime}',
                        size: design.typography.fontSize200.value,
                        semantic: TextSemantic.detail,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }
                ),
                GestureDetector(
                  onTap: () => next(),
                  child: Icon(
                    SpectrumIcons.smock_chevronright,
                    color: design.colors.gray.shade900,
                  ),
                ),
              ],
            ),
            ActionGroup(
              items: const [
                ActionItem(
                  icon: SpectrumIcons.smock_viewlist,
                ),
                ActionItem(
                  icon: SpectrumIcons.smock_viewgrid,
                )
              ],
              onChange: (d) => setState(
                  () => isGridView = d[0].icon == SpectrumIcons.smock_viewgrid),
              enableSelection: true,
              allowEmptySelection: false,
              selectionMode: SelectionMode.single,
              size: ButtonSize.small,
            ),
          ],
        ),
        isGridView
            ? Padding(
                padding: design.layout.spacing100.top,
                child: DiaryPageGridView(
                  api: widget.api,
                  fromDate: formatDate(currentFromDate),
                  intervalStream: intervalSubject,
                  controller: widget.contentScroll,
                ),
              )
            : DiaryPageLineView(
                api: widget.api,
                currentFromDate: formatDate(currentFromDate),
                intervalStream: intervalSubject,
              )
      ],
    );
  }

  Duration week = const Duration(days: 7);
  Duration halfOfMouth = const Duration(days: 15);

  String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  void next() {
    if(isGridView) {
      widget.api.nextDiaryPage();
    } else {
      setState(() => currentFromDate = currentFromDate.add(week));
    }
  }

  void previus() {
    if(isGridView) {
      widget.api.previusDiaryPage();
    } else {
    setState(() => currentFromDate = currentFromDate.subtract(isGridView ? halfOfMouth : week));
  }}
}
