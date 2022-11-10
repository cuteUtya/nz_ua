import 'dart:async';

import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/Components/MarkDisplay.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:nz_ua/nzsiteapi/types.dart';
import 'package:rxdart/rxdart.dart';

class DiaryPageGridView extends StatefulWidget {
  const DiaryPageGridView({
    Key? key,
    required this.api,
    required this.fromDate,
    required this.intervalStream,
    required this.controller,
  }) : super(key: key);
  final NzApi api;
  final String fromDate;
  final BehaviorSubject<DateTimeInterval> intervalStream;
  final ScrollController controller;
  @override
  State<StatefulWidget> createState() => DiaryPageGridViewState();
}

class DiaryPageGridViewState extends State<DiaryPageGridView> {
  DiaryMarkGrid? value;
  GlobalKey tableKey = GlobalKey();

  @override
  void initState() {
    listenNewValues();
    super.initState();
  }

  StreamSubscription? stream;

  void listenNewValues() {
    var stream = widget.api.diaryContentGrid.listen((event) {
      setState(() => value = event);
    });
  }

  @override
  void dispose() {
    stream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print(tableKey.currentContext?.size);
    });

    if (value == null) {
      widget.api.forceUpdateGridDiary(fromDate: widget.fromDate);
      return Container();
    }

    if (value!.interval != null) widget.intervalStream.add(value!.interval!);

    var radius = const BorderRadius.all(Radius.circular(5));

    var firstDay = DateTime.parse(value!.interval!.fromTime!).day;

    print(value?.lines?[0].marks?.length);

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: design.colors.gray.shade300, width: 2)),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: 800,
                  child: InformationTable(
                    key: tableKey,
                    externalBorder: false,
                    content: [
                      [
                        Container(),
                        for(var i = 0; i < (value?.lines?[0].marks?.length ?? 16) ; i++)
                          Padding(
                            padding: design.layout.spacing75.all,
                            child:  Text.rich(
                              design.typography.text(
                                  (i + firstDay).toString(),
                                size:
                                design.typography.fontSize75.value,
                                color: i == DateTime.now().day ? design.colors.red.shade600 : null,
                                semantic: TextSemantic.heading
                              ),
                            ),
                          ),
                      ],
                      if (value!.lines != null)
                        for (var line in value!.lines!)
                          [
                            if (line.lessonName != null)
                              Row(
                                children: [
                                  Padding(
                                    padding: design.layout.spacing75.all,
                                    child: Text.rich(
                                      design.typography.text(
                                        line.lessonName!,
                                        size:
                                            design.typography.fontSize75.value,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                ],
                              ),
                            if (line.marks != null)
                              for (var cell in line.marks!)
                                if (cell.contains(',') ||
                                    int.tryParse(cell) != null)
                                  Padding(
                                    padding: design.layout.spacing75.all,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          for (var mark in cell.split(','))
                                            design.typography.text(
                                              mark,
                                              size: design
                                                  .typography.fontSize100.value,
                                              color: MarkDisplay.getColorOfMark(
                                                int.tryParse(mark),
                                              ),
                                            ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  Container()
                          ]
                    ],
                    columnsSize: const [
                      0.45,
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  String g(String s) {
    return s;
  }
}
