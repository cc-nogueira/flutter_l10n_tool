import 'package:riverpod/riverpod.dart';

import '../../entity/arb/arb_definition.dart';
import 'change_control_scope.dart';

part 'change_control_providers.dart';

class ChangeControlUsecase {
  ChangeControlUsecase(this.read);

  final Reader read;

  void initScope() {
    read(_changeControlScopeProvider.notifier).state = ChangeControlScope();
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
    final scope = read(_changeControlScopeProvider);
    return read(scope.selectedChangeDefinitionProvider.notifier);
  }
}
