import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';

abstract class ConfigurationFormDropdown extends ConsumerWidget {
  const ConfigurationFormDropdown({
    super.key,
    required this.loc,
    required this.label,
  });

  final AppLocalizations loc;
  final String label;

  final List<bool> _options = const [true, false];

  bool value(WidgetRef ref, AlwaysAliveProviderBase<L10nConfiguration> provider);
  void setValue(Reader read, bool? value);
  String optionLabel(bool value);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final formValue = value(ref, formConfigurationProvider);
    final isModified = value(ref, projectConfigurationProvider) != formValue;
    return DropdownButtonFormField(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        enabledBorder: _enabledBorder(colors, isModified),
        focusedBorder: _focusedBorder(colors, isModified),
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      value: formValue,
      items: _items(currentValue: formValue),
      selectedItemBuilder: (_) => _selectedItems(),
      alignment: AlignmentDirectional.bottomStart,
      onChanged: (bool? value) => setValue(ref.read, value),
      isExpanded: true,
      focusColor: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
    );
  }

  List<DropdownMenuItem<bool>> _items({required bool currentValue}) {
    return _options.map((each) {
      final child = each == currentValue
          ? Row(children: [
              Text(optionLabel(each), style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 20),
              const Icon(Icons.check, size: 20),
            ])
          : Text(optionLabel(each), style: const TextStyle(fontSize: 14));
      return DropdownMenuItem(value: each, child: child);
    }).toList();
  }

  List<Widget> _selectedItems() => _options
      .map((each) => Text(optionLabel(each), style: const TextStyle(fontSize: 14)))
      .toList();

  InputBorder? _enabledBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 1.2))
      : null;

  InputBorder? _focusedBorder(ColorScheme colors, bool modified) => modified
      ? OutlineInputBorder(borderSide: BorderSide(color: colors.onPrimaryContainer, width: 2.0))
      : null;
}

class RequiredResouceAttributesDropdown extends ConfigurationFormDropdown {
  const RequiredResouceAttributesDropdown({super.key, required super.loc})
      : super(label: 'required attributes');

  @override
  bool value(WidgetRef ref, AlwaysAliveProviderBase<L10nConfiguration> provider) =>
      ref.watch(provider.select((value) => value.requiredResourceAttributes));

  @override
  void setValue(Reader read, bool? value) => read(formConfigurationProvider.notifier)
      .update((state) => state.copyWith(requiredResourceAttributes: value ?? false));

  @override
  String optionLabel(bool value) =>
      value ? 'require attribute to all resources' : 'don\'t require resource attributes';
}

class UseSyntheticPackageDropdown extends ConfigurationFormDropdown {
  const UseSyntheticPackageDropdown({super.key, required super.loc})
      : super(label: 'synthetic package');

  @override
  bool value(WidgetRef ref, AlwaysAliveProviderBase<L10nConfiguration> provider) =>
      ref.watch(provider.select((value) => value.syntheticPackage));

  @override
  void setValue(Reader read, bool? value) => read(formConfigurationProvider.notifier)
      .update((state) => state.copyWith(syntheticPackage: value ?? true));

  @override
  String optionLabel(bool value) => value ? 'use synthetic package' : 'use output folder';
}

class NullableGetterDropdown extends ConfigurationFormDropdown {
  const NullableGetterDropdown({super.key, required super.loc}) : super(label: 'nullable getter');

  @override
  bool value(WidgetRef ref, AlwaysAliveProviderBase<L10nConfiguration> provider) =>
      ref.watch(provider.select((value) => value.nullableGetter));

  @override
  void setValue(Reader read, bool? value) => read(formConfigurationProvider.notifier)
      .update((state) => state.copyWith(nullableGetter: value ?? true));

  @override
  String optionLabel(bool value) =>
      value ? 'generate nullable getter' : 'generate non nullable getter';
}
