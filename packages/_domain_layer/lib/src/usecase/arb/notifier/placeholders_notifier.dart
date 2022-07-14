part of '../arb_usecase.dart';

/// Arb usecase notifier for placeholders modified or being edited.
///
/// This is a public notifier acessible through corresponding providers:
///  - [beingEditedPlaceholdersProvider] and
///  - [formPlaceholdersProvider].
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class PlaceholdersNotifier extends MapNotifier<ArbDefinition, ArbPlaceholder> {}
