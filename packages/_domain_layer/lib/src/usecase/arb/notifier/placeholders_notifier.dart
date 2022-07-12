part of '../arb_usecase.dart';

/// Arb usecase notifier for definitions modified or being edited.
///
/// This is a public notifier acessible through corresponding providers:
///  - [beingEditedDefinitionsProvider] and
///  - [currentDefinitionsProvider].
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class PlaceholdersNotifier extends MapNotifier<ArbDefinition, ArbPlaceholder> {}
