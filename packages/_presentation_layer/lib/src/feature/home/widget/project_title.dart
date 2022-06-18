import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';

class ProjectTitle extends ConsumerWidget {
  const ProjectTitle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    if (project.path.isEmpty) {
      final loc = AppLocalizations.of(context);
      return Text(loc.title_home_page);
    }
    final colors = Theme.of(context).colorScheme;
    final nameStyle = TextStyle(fontWeight: FontWeight.w400, color: colors.onSurface);
    final pathStyle = TextStyle(fontWeight: FontWeight.w300, color: colors.onSurfaceVariant);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(project.name, style: nameStyle),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            project.path,
            style: pathStyle,
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
