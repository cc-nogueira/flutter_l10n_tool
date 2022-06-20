import 'package:flutter/material.dart';

class LabelDivider extends StatelessWidget {
  const LabelDivider({
    super.key,
    this.padding,
    required this.label,
    this.height,
    this.separation,
    this.thickness,
    this.color,
    this.leftLength,
    this.leftStartIndent,
    this.leftEndIndent,
    this.rightLength,
    this.rightStartIndent,
    this.rightEndIndent,
  });

  final EdgeInsets? padding;
  final Widget label;
  final double? height;
  final double? separation;
  final double? thickness;
  final double? leftLength;
  final double? leftStartIndent;
  final double? leftEndIndent;
  final double? rightLength;
  final double? rightStartIndent;
  final double? rightEndIndent;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final widget = Row(children: [
      _startDivider,
      if (separation != null) SizedBox(width: separation),
      label,
      if (separation != null) SizedBox(width: separation),
      _endDivider,
    ]);
    return padding == null ? widget : Padding(padding: padding!, child: widget);
  }

  Widget get _startDivider => _divider(
        length: leftLength,
        color: color,
        indent: leftStartIndent,
        endIndent: leftEndIndent,
      );

  Widget get _endDivider => _divider(
        length: rightLength,
        color: color,
        indent: rightStartIndent,
        endIndent: rightEndIndent,
      );

  Widget _divider({double? length, double? indent, double? endIndent, Color? color}) {
    final divider = Divider(
      height: height,
      thickness: thickness,
      color: color,
      indent: indent,
      endIndent: endIndent,
    );
    return length == null ? Expanded(child: divider) : SizedBox(width: length, child: divider);
  }
}
