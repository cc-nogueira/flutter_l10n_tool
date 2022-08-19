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
      margin: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: const [
          ResourceDisplayOptions(),
          FormMixin.horizontalSeparator,
          LocaleOptions(showSelectedMark: true),
        ],
      ),
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
      mainAxisSize: MainAxisSize.min,
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
    final selected = currentOption == option;
    return segmentedTextButton(
        align: align,
        colors: theme.colorScheme,
        text: option.text(loc),
        style: _style(theme.textTheme, selected),
        minimumSize: const Size(0, 36),
        onPressed: () => _onDisplayOptionPressed(option),
        selected: selected);
  }

  void _onDisplayOptionPressed(DisplayOption option) {
    if (currentOption != option) {
      onChanged(option);
    }
  }

  TextStyle? _style(TextTheme theme, bool selected) =>
      selected ? theme.bodySmall?.copyWith(fontWeight: FontWeight.w500) : theme.bodySmall;
}

class LocaleOptions extends ConsumerWidget {
  const LocaleOptions({super.key, required this.showSelectedMark});

  final bool showSelectedMark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locales = ref.watch(projectProvider).translations.keys.toList();
    final selectedLocales = ref.watch(selectedLocalesProvider);
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
    this.selectedLocales, {
    required this.showSelectedMark,
  });

  final Reader read;
  final List<String> locales;
  final Set<String> selectedLocales;
  final bool showSelectedMark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ..._localeButtons(textTheme, colors),
        clearFiltersButton(colors, () => _onClearLocalesFilter(read)),
      ],
    );
  }

  List<Widget> _localeButtons(TextTheme theme, ColorScheme colors) {
    final length = locales.length;
    if (length < 60) {
      return <Widget>[
        for (int idx = 0; idx < locales.length; ++idx)
          segmentedTextButton(
            colors: colors,
            minimumSize: const Size(0, 36),
            showSelectedMark: showSelectedMark,
            noSplash: true,
            style: _style(theme, selectedLocales.contains(locales[idx])),
            align: idx == 0
                ? MainAxisAlignment.start
                : idx == length - 1
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
            selected: selectedLocales.contains(locales[idx]),
            text: locales[idx],
            onPressed: () => onLocalesFilterPressed(read, locales[idx]),
          ),
      ];
    }
    return [];
  }

  void onLocalesFilterPressed(Reader read, String locale) {
    final localesFilterNotifier = read(selectedLocalesProvider.notifier);
    localesFilterNotifier.update(
      (state) {
        if (state.contains(locale)) {
          return {
            for (final each in state)
              if (each != locale) each,
          };
        }
        if (state.isNotEmpty) {
          return {...state, locale};
        }
        final first = read(allLocalesProvider).first;
        return {first, locale};
      },
    );
  }

  void _onClearLocalesFilter(Reader read) => read(selectedLocalesProvider.notifier).state = {};

  TextStyle? _style(TextTheme theme, bool selected) =>
      selected ? theme.bodySmall?.copyWith(fontWeight: FontWeight.w600) : theme.bodySmall;
}
