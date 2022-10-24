import 'dart:math';

import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/material.dart';

class InformationTable extends StatefulWidget {
  const InformationTable({
    Key? key,
    required this.title,
    required this.content,
    this.itemsAlign = Alignment.center,
    this.topBarColor,
  }) : super(key: key);
  final Color? topBarColor;
  final String title;
  final List<List<Widget>> content;
  final Alignment itemsAlign;


  @override
  State<StatefulWidget> createState() => _InformationTableState();
}

class _InformationTableState extends State<InformationTable> {
  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    var borderRadius = const BorderRadius.vertical(
      bottom: Radius.circular(5),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.topBarColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(5),
            ),
          ),
          padding: design.layout.spacing75.vertical,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text.rich(
                design.typography.text(
                  widget.title,
                  size: design.typography.fontSize100.value,
                  semantic: TextSemantic.heading,
                  color: Colors.white
                ),
              )
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: design.colors.gray.shade300,
            borderRadius: borderRadius,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: design.colors.gray.shade200,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(4),
              ),
            ),
            margin: const EdgeInsets.only(
              bottom: 2,
              right: 2,
              left: 2,
            ),
            child: buildContent(),
          ),
        ),
      ],
    );
  }

  Widget buildContent() {
    var design = Desing.of(context);

    List<Widget> content = [];

    for (var row in widget.content) {
      List<Widget> c = [];
      for (var child in row) {
        c.add(
          Expanded(
            child: Align(
              alignment:  widget.itemsAlign,
                child: child,
            ),
          ),
        );
        if (row.indexOf(child) != row.length - 1) {
          c.add(
            VerticalDivider(
              thickness: 2,
              color: design.colors.gray.shade300,
            ),
          );
        }
      }

      content.add(
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: c,
          ),
        ),
      );

      if (widget.content.indexOf(row) != widget.content.length - 1) {
        content.add(
          Container(
            width: double.infinity,
            height: 2,
            color: design.colors.gray.shade300,
          ),
        );
      }
    }

    return Column(
      children: content,
    );
  }
}
