import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';

class ChangeControlPage extends ConsumerWidget {
  const ChangeControlPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _NoResouceSelectedPage();
  }
}

class _NoResouceSelectedPage extends ConsumerWidget {
  const _NoResouceSelectedPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final select = ref.watch(selectedChangeDefinitionProvider);
    return select == null
        ? Padding(padding: const EdgeInsets.all(8.0), child: _noResourceSelected(context))
        : _ChangedResourcePage(select);
  }

  Widget _noResourceSelected(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Expanded(child: MessageWidget('No change selected')),
      ],
    );
  }
}

class _ChangedResourcePage extends ConsumerWidget {
  const _ChangedResourcePage(this.original);

  final ArbDefinition original;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: MessageWidget('changes to ${original.key}')),
      ],
    );
  }
}
