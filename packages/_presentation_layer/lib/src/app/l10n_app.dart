import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/page/message_page.dart';
import '../l10n/app_localizations.dart';
import '../provider/presentation_providers.dart';
import '../routes/routes.dart';

/// Localization App is this application MaterialApp.
///
/// Besides the regular constructor there is L10n.error constructor to
/// handle initialization errors.
class L10nApp extends ConsumerWidget {
  /// Normal const contructor.
  const L10nApp({super.key}) : error = null;

  /// Error state constructor.
  const L10nApp.error(this.error, {super.key});

  /// Optional error object used by the Error constructor.
  final Object? error;

  /// Internal routes object.
  final _routes = const Routes();

  @override
  Widget build(BuildContext context, WidgetRef ref) => error == null ? _app(ref) : _errorApp;

  Widget _app(WidgetRef ref) {
    final locale = ref.watch(languageOptionProvider).locale;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context).title_home_page,
      localizationsDelegates: const [
        DomainLocalizations.delegate,
        ...AppLocalizations.localizationsDelegates
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      onGenerateRoute: _routes.onGenerateRoute,
      initialRoute: Routes.home,
    );
  }

  Widget get _errorApp => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        onGenerateTitle: (context) => AppLocalizations.of(context).title_home_page,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ErrorMessagePage(error!),
      );
}
