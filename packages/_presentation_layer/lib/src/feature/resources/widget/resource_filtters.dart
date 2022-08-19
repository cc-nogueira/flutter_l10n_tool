import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/buttons.dart';

final activeResourceFiltersProvider = StateProvider<Set<ResourceFilter>>((_) => {});

enum ResourceFilter {
  beingEdited,
  modified,
  added,
  withWarnings,
}

class ResourceFiltersWidget extends ConsumerWidget {
  const ResourceFiltersWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final activeFilters = ref.watch(activeResourceFiltersProvider);
    return Row(
      children: [
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.start,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          noSplash: true,
          selectedColor: Colors.white,
          selected: activeFilters.contains(ResourceFilter.beingEdited),
          child: const Icon(Icons.edit, size: 16),
          onPressed: () => _onFilterPressed(ref.read, ResourceFilter.beingEdited),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.center,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          selectedColor: Colors.white,
          noSplash: true,
          selected: activeFilters.contains(ResourceFilter.modified),
          child: const Icon(Icons.save, size: 16),
          onPressed: () => _onFilterPressed(ref.read, ResourceFilter.modified),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.center,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          noSplash: true,
          selectedColor: Colors.white,
          selected: activeFilters.contains(ResourceFilter.added),
          child: const Icon(Icons.add_box, size: 16),
          onPressed: () => _onFilterPressed(ref.read, ResourceFilter.added),
        ),
        segmentedButton(
          colors: colors,
          align: MainAxisAlignment.end,
          minimumSize: const Size(0, 36),
          showSelectedMark: false,
          selectedColor: Colors.amberAccent,
          noSplash: true,
          selected: activeFilters.contains(ResourceFilter.withWarnings),
          child: const Icon(Icons.warning_amber, size: 16),
          onPressed: () => _onFilterPressed(ref.read, ResourceFilter.withWarnings),
        ),
        clearFiltersButton(colors, () => _clearAll(ref.read)),
      ],
    );
  }

  void _onFilterPressed(Reader read, ResourceFilter filter) {
    read(activeResourceFiltersProvider.notifier).update((state) {
      if (state.contains(filter)) {
        return {
          for (final each in state)
            if (each != filter) each,
        };
      }
      return {...state, filter};
    });
  }

  void _clearAll(Reader read) => read(activeResourceFiltersProvider.notifier).state = {};
}
