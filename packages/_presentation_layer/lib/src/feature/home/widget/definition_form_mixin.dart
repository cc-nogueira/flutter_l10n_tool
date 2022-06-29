import 'package:flutter/material.dart';

mixin DefinitionFormMixin {
  Widget textField({
    required ColorScheme colors,
    required String label,
    String? hintText,
    required String originalText,
    required TextEditingController textController,
    required ValueChanged<String> onChanged,
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
}
