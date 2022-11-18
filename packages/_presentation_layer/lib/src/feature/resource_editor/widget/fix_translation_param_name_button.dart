import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/theme/warning_theme_extension.dart';

class FixTranslationParamNameButton<T extends ArbTranslation> extends ConsumerWidget {
  const FixTranslationParamNameButton({
    super.key,
    required this.definition,
    required this.translation,
    required this.onValueChanged,
  });

  final ArbDefinitionWithParameter definition;
  final T translation;
  final ValueChanged<T> onValueChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warning = Theme.of(context).extension<WarningTheme>();
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message: 'Current param name does not match param definition.',
      child: TextButton.icon(
        onPressed: () => _fix(ref),
        icon: Icon(Icons.error_outline, size: 20, color: warning?.iconColor),
        label: const Text('Fix Param Name'),
        style: TextButton.styleFrom(foregroundColor: warning?.backgroundColor),
      ),
    );
  }

  void _fix(WidgetRef ref) {
    final value = translation.maybeMap(
      plural: (trans) => trans.copyWith(parameterName: definition.parameterName),
      select: (trans) => trans.copyWith(parameterName: definition.parameterName),
      orElse: () => translation,
    );
    onValueChanged(value as T);
  }
}
