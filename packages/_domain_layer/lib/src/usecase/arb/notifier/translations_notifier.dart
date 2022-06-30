part of '../arb_usecase.dart';

/// Arb usecase notifier for translations modified or being edited.
///
/// This is a public notifier acessible through corresponding providers:
///  - [beingEditedTranslationsProvider] and
///  - [currentTranslationsProvider].
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class TranslationsNotifier extends MapOneToManyNotifier<ArbDefinition, ArbTranslation> {}

/// Arb usecase notifier for translations being edited for a language.
///
/// This is a public notifier acessible through the [beingEditedTranslationsForLanguageProvider] family
/// provider variable. It is thus a collection of providers managing translations being edited for
/// each language.
///
/// Changes are only possible through the [ArbUsecase] (private methods).
class TranslationsForLanguageNotifier extends MapNotifier<ArbTranslation, ArbTranslation> {
  TranslationsForLanguageNotifier(this.locale);

  /// The locale of each provider in this family.
  final String locale;
}