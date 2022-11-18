import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'warning_theme_extension.dart';

/// ThemeBuilder for Material3.
///
/// The object of this class is created with a flag to define weather to use the pre generated
/// colorsSchemes or to customize flutter default colorSchemes for Dark and Light modes.
///
/// The default choice is to use the pre generated colorSchemes.
///
/// Exposes a dark and a light theme option.
class ThemeBuilder {
  /// Contructor receives a flag to define the use of pre generated themes (defaults to true).
  ThemeBuilder({this.useGenerated = true});

  /// Flag to define the use of pre generated themes.
  final bool useGenerated;

  /// Getter for darkTheme
  late ThemeData darkTheme = _theme(ThemeMode.dark);

  /// Getter for lightTheme
  late ThemeData lightTheme = _theme(ThemeMode.light);

  /// Configures ThemeData for a ThemeMode.
  ///
  /// ThemeData is flaged to useMaterial3.
  /// Handle only dark and light options, ThemeMode.system will be handled as dark.
  ///
  /// Also configures scaffoldBackgroundColor.
  ThemeData _theme(ThemeMode mode) {
    const warningTheme = WarningTheme(
      foregroundColor: Colors.black,
      backgroundColor: Colors.amber,
      iconColor: Colors.amberAccent,
    );
    final base = mode == ThemeMode.light
        ? ThemeData(
            brightness: Brightness.light,
            useMaterial3: true,
            colorScheme: useGenerated ? lightColorScheme : null,
            extensions: const <ThemeExtension<dynamic>>[warningTheme])
        : ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: useGenerated ? darkColorScheme : null,
            extensions: const <ThemeExtension<dynamic>>[warningTheme]);

    if (useGenerated) {
      return base.copyWith(scaffoldBackgroundColor: base.colorScheme.surface);
    }

    return base.copyWith(
      colorScheme: _colorScheme(mode, base.colorScheme),
      textTheme: _textTheme(mode, base.textTheme),
      appBarTheme: _appBarTheme(mode, base.appBarTheme),
      scaffoldBackgroundColor: _scaffoldBackgroundColor(mode),
    );
  }

  ColorScheme _colorScheme(ThemeMode mode, ColorScheme base) =>
      mode == ThemeMode.dark ? base : base.copyWith(onSurface: Colors.brown[900]);

  TextTheme _textTheme(ThemeMode mode, TextTheme base) =>
      mode == ThemeMode.dark ? base : base.apply(bodyColor: Colors.brown[900]);

  AppBarTheme _appBarTheme(ThemeMode mode, AppBarTheme base) =>
      base.copyWith(backgroundColor: _scaffoldBackgroundColor(mode));

  Color _scaffoldBackgroundColor(ThemeMode mode) =>
      mode == ThemeMode.dark ? Colors.grey[900]! : const Color(0xFFCACAC0);
}
