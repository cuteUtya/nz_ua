import 'package:design_system_provider/desing_provider.dart';
import 'package:design_system_provider/desing_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nz_ua/nzsiteapi/types.dart';

class MarkDisplay extends StatelessWidget {
  const MarkDisplay({
    Key? key,
    required this.mark,
  }) : super(key: key);
  final int? mark;
  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      width: 24,
      height: 24,
      //TODO bruh
      padding: const EdgeInsets.only(top: 3),
      child: Center(
        child: Text.rich(
          design.typography.text(
            (mark ?? -1).toString(),
            size: design.typography.fontSize100.value,
            semantic: TextSemantic.heading,
            color: getColorOfMark(mark)
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static getColorOfMark(int? mark) => {
    12: const Color(0xFF11B200),
    11: const Color(0xFF56BA00),
    10: const Color(0xFF81C000),
    9: const Color(0xFFA9C000),
    8: const Color(0xFFDBC000),
    7: const Color(0xFFF4C000),
    6: const Color(0xFFFFB300),
    5: const Color(0xFFFF9C00),
  }[mark ?? 12] ??
      const Color(0xFFFF4F00);
}
