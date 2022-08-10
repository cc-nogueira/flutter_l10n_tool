import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

mixin TextFormFieldMixin {
  static final _keyRegExp = RegExp(r'[_a-zA-Z]\w*');
  static final _publicVariableRegExp = RegExp(r'[a-zA-Z]\w*');
  static final _wordRegExp = RegExp(r'\w+');

  TextInputFormatter get textInputKeyFormatter =>
      TextInputFormatter.withFunction(_keyFormatterFunction);

  TextInputFormatter get textInputPublicVariableFormatter =>
      TextInputFormatter.withFunction(_publicVariableFormatterFunction);

  Widget textField({
    Key? key,
    required BuildContext context,
    required String label,
    String? hintText,
    required String originalText,
    TextEditingController? textController,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    List<TextInputFormatter>? inputFormatters,
    bool enabled = true,
    bool readOnly = false,
    int? maxLines,
    bool enableCleanButton = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    final isModified = textController != null && textController.text != originalText;
    return TextFormField(
      key: key,
      controller: textController,
      initialValue: textController == null ? originalText : null,
      enabled: enabled,
      readOnly: readOnly,
      style: readOnly
          ? TextStyle(fontSize: 14, color: colors.onPrimaryContainer, fontWeight: FontWeight.normal)
          : const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 0.0),
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, isModified),
        focusedBorder: _focusedBorder(colors, isModified),
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
        suffixIcon: !enableCleanButton || textController == null || textController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'clear',
                onPressed: () {
                  textController.clear();
                  onChanged?.call('');
                },
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
              ),
      ),
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      focusNode: focusNode,
      onEditingComplete: nextFocus == null || focusNode == null
          ? null
          : () {
              focusNode.unfocus();
              FocusScope.of(context).requestFocus(nextFocus);
            },
      maxLines: maxLines,
      validator: validator,
    );
  }

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;

  TextEditingValue _keyFormatterFunction(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final match = _keyRegExp.firstMatch(text);
    if (match == null) return const TextEditingValue();
    if (match.start == 0 && match.end == text.length) return newValue;

    final prefix = match.group(0)!;
    final leftTrim = match.start;
    final prefixEnd = leftTrim + prefix.length;
    final remain = text.substring(prefixEnd);

    final valueBuffer = StringBuffer(prefix);
    final matches = _wordRegExp.allMatches(remain);
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

  TextEditingValue _publicVariableFormatterFunction(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    final match = _publicVariableRegExp.firstMatch(text);
    if (match == null) return const TextEditingValue();
    if (match.start == 0 && match.end == text.length) return newValue;

    final prefix = match.group(0)!;
    final leftTrim = match.start;
    final prefixEnd = leftTrim + prefix.length;
    final remain = text.substring(prefixEnd);

    final valueBuffer = StringBuffer(prefix);
    final matches = _wordRegExp.allMatches(remain);
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
