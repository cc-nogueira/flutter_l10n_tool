import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyseSelectedLocalesOnlyProvider = StateProvider(((ref) => true));

class AnalyseSelectedLocalesOnlySwitch extends ConsumerWidget {
  const AnalyseSelectedLocalesOnlySwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final considerLocales = ref.watch(analyseSelectedLocalesOnlyProvider);
    final style = considerLocales
        ? TextStyle(color: colors.onPrimaryContainer)
        : TextStyle(color: colors.secondary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: 23,
          child: FittedBox(child: Text('Analyse only selected locales:', style: style)),
        ),
        Switch(value: considerLocales, onChanged: (value) => _onChanged(ref.read, value)),
      ],
    );
  }

  void _onChanged(Reader read, bool? value) =>
      read(analyseSelectedLocalesOnlyProvider.notifier).state = value == true;
}
