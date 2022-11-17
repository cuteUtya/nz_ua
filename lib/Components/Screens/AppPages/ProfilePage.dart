import 'dart:math';

import 'package:adobe_spectrum/Components/action_button.dart';
import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nz_ua/Components/Components/InformationTable.dart';
import 'package:nz_ua/Components/localization.dart';
import 'package:nz_ua/nzsiteapi/nz_api.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../nzsiteapi/types.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    Key? key,
    required this.api,
  }) : super(key: key);

  final NzApi api;

  @override
  State<StatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var graphics = [
    appLocalization.vi_piska,
    appLocalization.marks_for_period_by_values,
    appLocalization.average_mark_for_period_by_lessons,
  ];

  var fromDate = DateTime.now().subtract(const Duration(days: 31));
  var toDate = DateTime.now();

  late String? current = graphics.first;

  StudentPerfomanceResponce? data;

  void requestNewData() {
    widget.api
        .getPerfomance(
      fromDate: fromDate,
      toDate: toDate,
    )
        .then(
      (value) {
        setState(
          () {
            data = value;
          },
        );
      },
    );
  }

  @override
  void initState() {
    requestNewData();
    super.initState();
  }

  String formatDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    return StreamBuilder(
      stream: widget.api.profilePages,
      builder: (_, d) {
        ProfilePageState? profile;

        if (d.data != null) {
          profile = d.data as ProfilePageState;
        }

        if (profile?.profile == null) {
          widget.api.openProfile();
          return Container();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      profile!.profile!.photoProfileUrl!,
                      width: MediaQuery.of(context).size.width * 0.25,
                    ),
                    Padding(
                      padding: design.layout.spacing100.left,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              design.typography.text(
                                profile!.profile!.fullName ?? '',
                                size: design.typography.fontSize100.value,
                                semantic: TextSemantic.heading,
                              ),
                            ),
                            Text.rich(
                              design.typography.text(
                                profile!.profile!.birthDate ?? '',
                                size: design.typography.fontSize100.value,
                              ),
                            ),
                            Text.rich(
                              design.typography.text(
                                profile!.profile!.schoolName ?? '',
                                size: design.typography.fontSize100.value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: design.layout.spacing100.top,
              child: Text.rich(
                design.typography.text(
                  appLocalization.performance_analysis,
                  size: design.typography.fontSize200.value,
                  semantic: TextSemantic.heading,
                ),
              ),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                canvasColor: design.colors.gray.shade400,
              ),
              child: DropdownButton(
                value: current,
                items: graphics
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text.rich(
                          design.typography.text(
                            e,
                            size: design.typography.fontSize100.value,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => current = v),
              ),
            ),
            Padding(
              padding: design.layout.spacing100.top,
              child: Row(
                children: [
                  Flexible(
                    child: ActionButton(
                      groupPosition: GroupPosition.start,
                      label: formatDate(fromDate),
                      isSelected: true,
                      justified: true,
                      onClick: () async {
                        var d = await showDatePicker(
                          context: context,
                          initialDate: fromDate,
                          firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                          lastDate: toDate,
                        );
                        if (d != null) {
                          setState(() => fromDate = d);
                          requestNewData();
                        }
                      },
                    ),
                  ),
                  Flexible(
                    child: ActionButton(
                      groupPosition: GroupPosition.center,
                      label: appLocalization.time_to,
                      justified: true,
                    ),
                  ),
                  Flexible(
                    child: ActionButton(
                      groupPosition: GroupPosition.end,
                      label: formatDate(toDate),
                      isSelected: true,
                      justified: true,
                      onClick: () async {
                        var d = await showDatePicker(
                          context: context,
                          initialDate: toDate,
                          firstDate: DateTime.fromMicrosecondsSinceEpoch(0),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) {
                          setState(() => toDate = d);
                          requestNewData();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: design.layout.spacing100.top,
              child: buildCharts(),
            ),
          ],
        );
      },
    );
  }

  Widget buildCharts() {
    var design = Desing.of(context);
    if (data != null) {
      if (current == appLocalization.marks_for_period_by_values) {
        List<_ChartData> columns = [];

        for (int i = 1; i <= 12; i++) {
          double count = 0;
          for (var subject in data!.subjects ?? []) {
            for (var m in subject.marks ?? []) {
              var l = int.tryParse(m);
              if (l == i) count++;
            }
          }
          columns.add(_ChartData(i.toDouble(), count));
        }

        var d = columns.toList();
        columns.sort((a, b) => a.y.compareTo(b.y));

        return SfCartesianChart(
          primaryXAxis: NumericAxis(
            maximum: 12,
            minimum: 1,
            interval: 1,
            majorGridLines: MajorGridLines(width: 0),
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: ((columns.last.y ~/ 5).toInt() + 1) * 5,
            interval: 5,
          ),
          series: <ChartSeries<_ChartData, num>>[
            BarSeries<_ChartData, num>(
              dataSource: d,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
              xValueMapper: (_ChartData data, _) => data.x,
              yValueMapper: (_ChartData data, _) => data.y,
              color: design.colors.green.shade700,
            ),
          ],
        );
      } else if (current == appLocalization.vi_piska) {
        return InformationTable(
          columnsSize: const [0.1, 0.5],
          content: [
            [
              Text.rich(
                design.typography.text(
                  '№',
                  size: design.typography.fontSize100.value,
                ),
              ),
              Text.rich(
                design.typography.text(
                  appLocalization.lesson_name,
                  size: design.typography.fontSize100.value,
                ),
              ),
              Text.rich(
                design.typography.text(
                  appLocalization.obtained_results,
                  size: design.typography.fontSize100.value,
                ),
              ),
            ],
            for (var lesson in data!.subjects!)
              [
                Text.rich(
                  design.typography.text(
                    data!.subjects!.indexOf(lesson).toString(),
                    size: design.typography.fontSize100.value,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: design.layout.spacing75.left,
                      child: Text.rich(
                        design.typography.text(
                          lesson.subjectName ?? "",
                          size: design.typography.fontSize100.value,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: design.layout.spacing75.left,
                      child: Text.rich(
                        design.typography.text(
                          lesson.marks!.join(", "),
                          size: design.typography.fontSize100.value,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
          ],
        );
      } else if(current == appLocalization.average_mark_for_period_by_lessons) {
         var d = data!.subjects!.map((e) {
          var l = e.marks!.map((e) => int.parse(e)).reduce((a, b) => a + b);
          return _ChartData(data!.subjects!.indexOf(e).toDouble(), l / e.marks!.length);
        }).toList();

         return SfCartesianChart(
           primaryXAxis: CategoryAxis(
             majorGridLines: MajorGridLines(width: 0),
             labelPlacement: LabelPlacement.onTicks,
           ),
           primaryYAxis: NumericAxis(
             minimum: 0,
             maximum: 12,
             interval: 1,
             majorGridLines: MajorGridLines(width: 0),
           ),
           series: <ChartSeries<_ChartData, String>>[
             BarSeries<_ChartData, String>(
               width: 0.3,
               dataSource: d,
               borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
               xValueMapper: (_ChartData data, _) => this.data!.subjects![data.x.toInt()].subjectName ?? '' ,
               yValueMapper: (_ChartData data, _) => data.y,
               color: design.colors.green.shade700,
             ),
           ],
         );
         print(d);
      }
    }
    return Container();
  }
}

class _ChartData {
  _ChartData(this.x, this.y);

  final double x;
  final double y;
}
