import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import 'change_control_scope.dart';

part 'change_control_providers.dart';

class ChangeControlUsecase {
  ChangeControlUsecase(this.ref);

  final Ref ref;

  void initScope() {
    ref.read(_changeControlScopeProvider.notifier).state = ChangeControlScope();
  }

  /// Defines which [ArbDefinition] is currently being selected by the user.
  void select(ArbDefinition? definition) {
    _selectedChangeDefinitionNotifier().select(definition);
  }

  /// Toggle the selection of a [ArbDefinition].
  void toggle(ArbDefinition? definition) {
    _selectedChangeDefinitionNotifier().toggleSelect(definition);
  }

  /// Clear the current [ArbDefinition] selection.
  void clearSelection() {
    _selectedChangeDefinitionNotifier().clearSelection();
  }

  SelectedDefinitionNotifier _selectedChangeDefinitionNotifier() {
    final scope = ref.read(_changeControlScopeProvider);
    return ref.read(scope.selectedChangeDefinitionProvider.notifier);
  }
}
