import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

/// Container with title bar is used to present a scaffold title bar in the body of the scaffold.
///
/// This is used to allow custom title bars for Desktop platforms allowing extra flexibilitty not
/// necessary in Mobile platforms.
///
/// With this bitsdojo approach it is possible to create title less applications (like Spotify) that
/// renders minimize, maximize and close window buttons inside the app.
///
/// Renders a column with:
///  - title bar with dragTitle and a right aligned bar with minimize, maximize and close buttons.
///  - optional right aligned second row of buttons (action buttons).
///  - child widget in an expanded container.
class ContainerWithTitleBar extends StatelessWidget {
  /// Const constructor.
  const ContainerWithTitleBar({
    super.key,
    required this.title,
    this.leading,
    this.leadingWidth,
    this.actions,
    required this.child,
    this.titleButtonsBackgroundColor,
  });

  /// Title widget expanded at the fist row, contained in a dragWindow container.
  final Widget title;

  /// Leading widget (menu button, back button).
  final Widget? leading;

  /// Leading container width (defaults to 56.0)
  final double? leadingWidth;

  /// Optional actions buttons for a second row of right aligned buttons.
  final List<Widget>? actions;

  /// Expanded child after the title bar
  final Widget child;

  /// Optional title buttons background color (defaults to light shadded transparency).
  final Color? titleButtonsBackgroundColor;

  /// Build the container with title bar and expanded child.
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        _titleBar(context),
        Expanded(child: child),
      ],
    );
  }

  /// Internal - title bar with drag title and trailing controls.
  Widget _titleBar(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) SizedBox(width: leadingWidth ?? 56.0, child: leading!),
          _dragTitle(),
          _trailingControls(context),
        ],
      ),
    );
  }

  /// Internal - expanded title inside a drag window container.
  Widget _dragTitle() => Expanded(
        child: GestureDetector(
          onPanStart: (_) => appWindow.startDragging(),
          child: Container(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            decoration: const BoxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title],
            ),
          ),
        ),
      );

  /// Internal - trailing controls.
  ///
  /// These controls include a row with window buttons (minimize, maximize and close) and an
  /// optional row with action buttons.
  Widget _trailingControls(BuildContext context) {
    final windowButtons = Container(
      color: _buttonsBgColor(context),
      height: appWindow.titleBarHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [MinimizeWindowButton(), MaximizeWindowButton(), CloseWindowButton()],
      ),
    );
    if (actions == null) {
      return windowButtons;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        windowButtons,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: actions!,
        ),
      ],
    );
  }

  /// Internal - window buttons background color.
  ///
  /// Default to a light shade, intensity of shadding according to theme brightness.
  Color? _buttonsBgColor(BuildContext context) =>
      titleButtonsBackgroundColor ??
      (Theme.of(context).brightness == Brightness.dark ? Colors.black26 : Colors.black12);
}

/// Container with title bar widget is used to present a scaffold title bar in the body of the scaffold.
///
/// This is used to allow custom title bars for Desktop platforms allowing extra flexibilitty not
/// necessary in Mobile platforms.
///
/// With this bitsdojo approach it is possible to create title less applications (like Spotify) that
/// renders minimize, maximize and close window buttons inside the app.
///
/// It will return a Column widget with a internal title bar, followed or embedded with an optional
/// appBar and finally followed by and expanded child widget.
class ContainerWithAppBar extends StatelessWidget {
  const ContainerWithAppBar(
      {super.key, this.appBar, required this.child, this.embeddedAppBar = false});

  final Widget? appBar;
  final Widget child;
  final bool embeddedAppBar;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        WindowTitleBarBox(
          child: Row(
            children: [
              Expanded(child: MoveWindow(child: embeddedAppBar ? appBar : null)),
              MinimizeWindowButton(),
              MaximizeWindowButton(),
              CloseWindowButton(),
            ],
          ),
        ),
        if (!embeddedAppBar && appBar != null) appBar!,
        Expanded(child: child),
      ],
    );
  }
}
