import 'package:_domain_layer/domain_layer.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../navigation/navigation_drawer_option.dart';

/// Abstract class defines the common structure of blanka project navigation drawer.
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
    this.headerDependOnProjectLoaded = true,
    this.bodyDependOnProjectLoaded = true,
    this.childrenPadding = const EdgeInsets.symmetric(horizontal: 8.0),
  });

  /// Navigation option.
  final NavigationDrawerOption option;

  /// Children column padding, defaults to EdgeInsets.symmetric(horizontal: 8.0).
  final EdgeInsets childrenPadding;

  /// Drawer width, defaults to 304 (Drawer default _kWidth)
  final double width;

  /// Drawer header depend on project being loaded
  final bool headerDependOnProjectLoaded;

  /// Drawer body depend on project being loaded
  final bool bodyDependOnProjectLoaded;

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
            child: _body(context, ref, loc),
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
    final child = _projectNotLoadedHeaderMsg(colors, ref, loc) ?? headerChild(context, ref, loc);
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
                    if (child != null)
                      Expanded(
                        child: Padding(
                          padding: headerChildPadding,
                          child: child,
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

  Widget? _projectNotLoadedHeaderMsg(ColorScheme colors, WidgetRef ref, AppLocalizations loc) {
    if (headerDependOnProjectLoaded) {
      final projectLoaded = ref.watch(isProjectLoadedProvider);
      if (!projectLoaded) {
        final nameStyle = TextStyle(fontWeight: FontWeight.w400, color: colors.onSurface);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('(${loc.message_no_project_selected})', style: nameStyle),
          ],
        );
      }
    }
    return null;
  }

  /// Abstract localized header title text for [_header] builder.
  String titleText(AppLocalizations loc);

  /// Subclasses may define children for the [_header] builder.
  Widget? headerChild(BuildContext context, WidgetRef ref, AppLocalizations loc) => null;

  EdgeInsetsGeometry get headerChildPadding => const EdgeInsets.symmetric(horizontal: 16.0);

  Widget _body(BuildContext context, WidgetRef ref, AppLocalizations loc) {
    return _projectNotLoadedBody(ref) ??
        Padding(
          padding: childrenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children(context, ref, loc),
          ),
        );
  }

  Widget? _projectNotLoadedBody(WidgetRef ref) {
    if (bodyDependOnProjectLoaded) {
      final projectLoaded = ref.watch(isProjectLoadedProvider);
      if (!projectLoaded) {
        return Container();
      }
    }
    return null;
  }

  /// Subclasses may define drawer's content that comes after the [_header].
  List<Widget> children(BuildContext context, WidgetRef ref, AppLocalizations loc) => [];
}
