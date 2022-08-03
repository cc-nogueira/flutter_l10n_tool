import 'package:flutter/material.dart';

class FormDropdown<T> extends StatelessWidget {
  const FormDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.optionLabel,
    required this.originalValue,
    required this.formValue,
    required this.onChanged,
    this.focusNode,
  });

  final String label;
  final FocusNode? focusNode;
  final List<T> options;
  final T originalValue;
  final T formValue;
  final ValueChanged<T?> onChanged;
  final String Function(T value) optionLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isModified = originalValue != formValue;
    final containsValue = options.contains(formValue);
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 8.0),
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, isModified),
        focusedBorder: _focusedBorder(colors, isModified),
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      isExpanded: true,
      alignment: AlignmentDirectional.bottomStart,
      focusColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      value: containsValue ? formValue : null,
      items: _items(value: formValue),
      selectedItemBuilder: (_) => _selectedItems(),
      focusNode: focusNode,
      onChanged: (value) => onChanged(value),
    );
  }

  List<DropdownMenuItem<T>> _items({required T value}) {
    return options.map((each) {
      final child = each == value
          ? Row(children: [
              Text(optionLabel(each), style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 20),
              const Icon(Icons.check, size: 20),
            ])
          : Text(optionLabel(each), style: const TextStyle(fontSize: 14));
      return DropdownMenuItem(value: each, child: child);
    }).toList();
  }

  List<Widget> _selectedItems() =>
      options.map((each) => Text(optionLabel(each), style: const TextStyle(fontSize: 14))).toList();

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;
}
