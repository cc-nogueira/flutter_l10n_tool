import 'dart:math';

import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin DefinitionFormMixin {
  static final keyRegExp = RegExp(r'[_a-zA-Z]\w*');
  static final wordRegExp = RegExp(r'\w+');
  static const leadingIcon = Icon(Icons.key);
  static const leadingSize = 40.0;
  static const leadingSeparation = 12.0;
  static const leadingSeparator = SizedBox(width: leadingSeparation);
  static const verticalSeparator = SizedBox(height: 16);

  Widget tileIcon() =>
      const SizedBox(width: leadingSize, height: leadingSize, child: Center(child: leadingIcon));

  Widget textField({
    required ColorScheme colors,
    required String label,
    String? hintText,
    required String originalText,
    required TextEditingController textController,
    required ValueChanged<String> onChanged,
    List<TextInputFormatter>? inputFormatters,
    int? maxLines,
  }) {
    final hasChanges = textController.text != originalText;
    return TextFormField(
      controller: textController,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 0.0),
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, hasChanges),
        focusedBorder: _focusedBorder(colors, hasChanges),
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
      ),
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;

  TextInputFormatter get keyFormatter => TextInputFormatter.withFunction(keyFormatterFunction);

  TextEditingValue keyFormatterFunction(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final match = ArbUtil.keyRegExp.firstMatch(text);
    if (match == null) return const TextEditingValue();
    if (match.start == 0 && match.end == text.length) return newValue;

    final prefix = match.group(0)!;
    final leftTrim = match.start;
    final prefixEnd = leftTrim + prefix.length;
    final remain = text.substring(prefixEnd);

    final valueBuffer = StringBuffer(prefix);
    final matches = wordRegExp.allMatches(remain);
    var moreTrim = 0;
    var prevEnd = 0;
    for (final match in matches) {
      if (prefixEnd + match.start <= newValue.selection.baseOffset) {
        moreTrim += match.start - prevEnd;
        prevEnd = match.end;
      }
      valueBuffer.write(match.group(0)!);
    }

    final newText = valueBuffer.toString();
    final baseOffset = max(
      min(newValue.selection.baseOffset - leftTrim - moreTrim, newText.length),
      0,
    );
    final newSelection = TextSelection(baseOffset: baseOffset, extentOffset: baseOffset);
    return TextEditingValue(text: newText, selection: newSelection);
  }
}
