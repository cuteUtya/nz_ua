import 'dart:math';

import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/material.dart';

class InformationTable extends StatefulWidget {
  const InformationTable({
    Key? key,
    this.title,
    required this.content,
    this.itemsAlign = Alignment.center,
    this.topBarColor,
    this.columnsSize,
    this.externalBorder = true,
  }) : super(key: key);
  final Color? topBarColor;
  final String? title;
  final List<List<Widget>> content;
  final Alignment itemsAlign;
  final List<double>? columnsSize;
  final bool externalBorder;

  @override
  State<StatefulWidget> createState() => _InformationTableState();
}

class _InformationTableState extends State<InformationTable> {
  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    var borderRadius = BorderRadius.vertical(
      bottom: const Radius.circular(5),
      top: widget.title == null ? const Radius.circular(5) : Radius.zero,
    );

    var content = buildContent(MediaQuery.of(context).size);

    return Column(
      children: [
        if (widget.title != null)
          Container(
            decoration: BoxDecoration(
              color: widget.topBarColor,
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(5),
                bottom: widget.title == null
                    ? const Radius.circular(5)
                    : Radius.zero,
              ),
            ),
            padding: design.layout.spacing75.vertical,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text.rich(
                  design.typography.text(widget.title!,
                      size: design.typography.fontSize100.value,
                      semantic: TextSemantic.heading,
                      color: Colors.white),
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
              borderRadius: BorderRadius.vertical(
                bottom: const Radius.circular(4),
                top: widget.title == null
                    ? const Radius.circular(4)
                    : Radius.zero,
              ),
            ),
            margin: widget.externalBorder
                ? EdgeInsets.only(
                    bottom: 2,
                    right: 2,
                    left: 2,
                    top: widget.title == null ? 2 : 0,
                  )
                : EdgeInsets.zero,
            child: content,
          ),
        ),
      ],
    );
  }

  Widget buildContent(Size size) {
    var design = Desing.of(context);

    List<Widget> content = [];

    for (var row in widget.content) {
      List<Widget> c = [];
      for (var child in row) {
        var s1 = Container(
          margin: EdgeInsets.only(top: 2, left: 2),
          child: Align(
            alignment: widget.itemsAlign,
            child: child,
          ),
        );

        double? columnSize;
        try {
          columnSize = widget.columnsSize![row.indexOf(child)];
        } catch (e) {
          //
        }

        c.add(
          widget.columnsSize == null || columnSize == null
              ? Expanded(
                  child: s1,
                )
              : SizedBox(
                  //TODO - 16 - 20? paddings?
                  width: (size.width - 16 - 20) * columnSize!,
                  height: double.infinity,
                  child: s1,
                ),
        );

        if (row.indexOf(child) != row.length - 1) {
          c.add(VerticalDivider(
            thickness: 2,
            color:  design.colors.gray.shade300,
            width: 0,
          ));
        }
      }

      if (widget.content.indexOf(row) != widget.content.length - 1) {
        content.add(
          Container(
            width: double.infinity,
            height: 1,
            color: design.colors.gray.shade300,
          ),
        );
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
            height: 1,
            color: design.colors.gray.shade300,
          ),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: content,
    );
  }
}
