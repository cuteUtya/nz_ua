import 'package:design_system_provider/desing_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextWithIcon extends StatelessWidget {
  const TextWithIcon({
    Key? key,
    required this.text,
    required this.icon,
  }) : super(key: key);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    var design = Desing.of(context);
    return Padding(padding: design.layout.spacing50.top, child:  Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: design.colors.gray.shade900,
          size: design.typography.fontSize200.value,
        ),
        Flexible(fit: FlexFit.loose, child:  Padding(
          padding: design.layout.spacing100.left.add(EdgeInsets.only(top: 2)),
          child:  Text.rich(
            design.typography.text(
              text,
              size: design.typography.fontSize75.value,
            ),),
          ),
        ),
      ],
    ),);
  }
}
