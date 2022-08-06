import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';

class ResourceBar extends StatelessWidget {
  const ResourceBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(children: const [
        ResourceDisplayOptions(),
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
        _button(loc, theme, MainAxisAlignment.start, DisplayOption.compact),
        _button(loc, theme, MainAxisAlignment.end, DisplayOption.expanded),
      ],
    );
  }

  Widget _button(
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
        onPressed: () => _onPressed(option),
        selected: currentOption == option);
  }

  void _onPressed(DisplayOption option) {
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
