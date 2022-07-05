import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../navigation/navigation_drawer_option.dart';

/// Abstract class defines the common structure of a project navigation drawer.
///
/// A drawer is defined to have a [_header] and an expanded column with its [children].
///
/// The header widget is built with a required [_titleText] and an optional list of [_headerChildren].
/// Header widget colors is retried from the [NavigationDrawerOption] received in the constructor.
abstract class NavigationDrawer extends ConsumerWidget {
  /// Const constructor.
  ///
  /// Receives this navigation drawer option.
  const NavigationDrawer(
    this.option, {
    super.key,
    this.width = 304,
    this.childrenPadding = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  /// Navigation option.
  final NavigationDrawerOption option;

  /// Children column padding, defaults to EdgeInsets.symmetric(horizontal: 8.0).
  final EdgeInsets childrenPadding;

  /// Drawer width, defaults to 304 (Drawer default _kWidth)
  final double width;

  /// Builds a drawer.
  ///
  /// A drawer is defined to have a [_header] and an expanded column with its [children].
  ///
  /// The header widget is built with a required [_titleText] and an optional list of [_headerChildren].
  /// Header widget colors is retried from the [NavigationDrawerOption] received in the constructor.
  ///
  /// The contents of this drawer can be defined in subclasses with the [children] method.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return Drawer(
      width: width,
      child: Column(
        children: [
          _header(context, ref, loc),
          Expanded(
            child: Padding(
              padding: childrenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children(context, ref, loc),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Internal - builds this drawer header.
  ///
  /// Returns a [DrawerHeader] with this option color.
  /// This header is a column with the require subclass defined [titleText] followed by optional
  /// subclass defined [headerChildren].
  Widget _header(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      height: 150,
      child: DrawerHeader(
        padding: EdgeInsets.zero,
        child: DecoratedBox(
          decoration: BoxDecoration(color: option.color(colors)),
          child: Row(
            children: [
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _dragTitle(Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Text(titleText(loc)),
                    )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: headerChildren(context, ref, loc),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dragTitle(Widget title) => Row(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (_) => appWindow.startDragging(),
              child: title,
            ),
          ),
        ],
      );

  /// Internal - expanded title inside a drag window container.
  Widget dragTitle(BuildContext context) => Expanded(
        child: GestureDetector(
          onPanStart: (_) => appWindow.startDragging(),
          child: Container(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [],
            ),
          ),
        ),
      );

  /// Abstract localized header title text for [_header] builder.
  String titleText(AppLocalizations loc);

  /// Subclasses may define children for the [_header] builder.
  List<Widget> headerChildren(BuildContext context, WidgetRef ref, AppLocalizations loc) => [];

  /// Subclasses may define drawer's content that comes after the [_header].
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) => [];
}
