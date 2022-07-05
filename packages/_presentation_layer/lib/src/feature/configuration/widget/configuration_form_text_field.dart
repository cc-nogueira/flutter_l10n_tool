import 'package:flutter/material.dart';

class ConfigurationFormTextField extends StatelessWidget {
  const ConfigurationFormTextField({
    super.key,
    required this.label,
    this.hintText,
    required this.textController,
    required this.currentValue,
    required this.setValue,
    this.focusNode,
    this.nextFocus,
    this.enabled = true,
    this.maxLines = 1,
  });

  final String label;
  final String? hintText;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final bool enabled;
  final int? maxLines;
  final String Function() currentValue;
  final ValueChanged<String> setValue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isModified = currentValue() != textController?.text;
    return TextFormField(
      controller: textController,
      enabled: enabled,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 0.0),
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, isModified),
        focusedBorder: _focusedBorder(colors, isModified),
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        counterText: '',
      ),
      onChanged: setValue,
      focusNode: focusNode,
      onEditingComplete: nextFocus == null || focusNode == null ? null : () => _focusNext(context),
      textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
      maxLines: maxLines,
    );
  }

  void _focusNext(BuildContext context) {
    focusNode?.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;
}
