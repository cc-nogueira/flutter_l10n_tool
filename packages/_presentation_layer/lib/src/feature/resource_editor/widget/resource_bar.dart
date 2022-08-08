import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';
import '../../../common/widget/form_mixin.dart';
import '../../../provider/presentation_providers.dart';

class ResourceBar extends StatelessWidget {
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(children: const [
        ResourceDisplayOptions(),
        FormMixin.horizontalSeparator,
        LocaleOptions(showSelectedMark: true),
      ]),
    );
  }
}

class ResourceDisplayOptions extends ConsumerWidget {
  const ResourceDisplayOptions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayOption = ref.watch(displayOptionProvider);
    return _ResourceDisplayOptions(
      currentOption: displayOption,
      onChanged: (option) => _onChanged(ref.read, option),
    );
  }

  void _onChanged(Reader read, DisplayOption option) {
    read(preferencesUsecaseProvider).displayOption = option;
  }
}

class _ResourceDisplayOptions extends StatelessWidget {
  const _ResourceDisplayOptions({required this.currentOption, required this.onChanged});

  final DisplayOption currentOption;
  final ValueChanged<DisplayOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final loc = DomainLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        _displayOptionButton(loc, theme, MainAxisAlignment.start, DisplayOption.compact),
        _displayOptionButton(loc, theme, MainAxisAlignment.end, DisplayOption.expanded),
      ],
    );
  }

  Widget _displayOptionButton(
    DomainLocalizations loc,
    ThemeData theme,
    MainAxisAlignment align,
    DisplayOption option,
  ) {
    return segmentedTextButton(
        align: align,
        colors: theme.colorScheme,
        text: option.text(loc),
        style: style(theme.textTheme, option),
        minimumSize: const Size(0, 36),
        onPressed: () => _onDisplayOptionPressed(option),
        selected: currentOption == option);
  }

  void _onDisplayOptionPressed(DisplayOption option) {
    if (currentOption != option) {
      onChanged(option);
    }
  }

  TextStyle? style(TextTheme theme, DisplayOption option) {
    return currentOption == option
        ? theme.bodySmall?.copyWith(fontWeight: FontWeight.w500)
        : theme.bodySmall;
  }
}

class LocaleOptions extends ConsumerWidget {
  const LocaleOptions({super.key, required this.showSelectedMark});

  final bool showSelectedMark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = ref.watch(projectProvider).translations.keys.toList();
    final selectedLocales = ref.watch(localesFilterProvider);
    if (locales.length < 2) {
      return Container();
    }
    return _LocaleOptions(ref.read, locales, selectedLocales, showSelectedMark: showSelectedMark);
  }
}

class _LocaleOptions extends StatelessWidget {
  const _LocaleOptions(
    this.read,
    this.locales,
    this.selectedLocaleFilters, {
    required this.showSelectedMark,
  });

  final Reader read;
  final List<String> locales;
  final List<bool> selectedLocaleFilters;
  final bool showSelectedMark;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(children: [
      ..._localeButtons(colors),
      clearFiltersButton(colors, () => onLocalesFilterPressed(read)),
    ]);
  }

  List<Widget> _localeButtons(ColorScheme colors) {
    final length = locales.length;
    if (length < 6) {
      return <Widget>[
        for (int idx = 0; idx < locales.length; ++idx)
          segmentedTextButton(
            colors: colors,
            selectedColor: Colors.white,
            minimumSize: const Size(0, 36),
            showSelectedMark: showSelectedMark,
            noSplash: true,
            align: idx == 0
                ? MainAxisAlignment.start
                : idx == length - 1
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
            selected: selectedLocaleFilters[idx],
            text: locales[idx],
            onPressed: () => onLocalesFilterPressed(read, idx),
          ),
      ];
    }
    return [];
  }

  void onLocalesFilterPressed(Reader read, [int? idx]) {
    final localesFilterNotifier = read(localesFilterProvider.notifier);
    final noneSelected = !localesFilterNotifier.state.any((value) => value);
    localesFilterNotifier.update(
      (state) => [
        for (int i = 0; i < state.length; ++i)
          idx == null
              ? false
              : i == idx
                  ? !state[i]
                  : noneSelected && i == 0 || state[i],
      ],
    );
  }
}
