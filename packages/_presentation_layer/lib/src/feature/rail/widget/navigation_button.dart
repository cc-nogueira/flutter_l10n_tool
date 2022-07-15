import 'package:flutter/material.dart';

class NavigationButton extends StatefulWidget {
  const NavigationButton(
    this.destination, {
    super.key,
    required this.isActive,
    required this.indicatorColor,
    required this.width,
    this.onTap,
  });

  final NavigationRailDestination destination;
  final Color indicatorColor;
  final bool isActive;
  final double width;
  final VoidCallback? onTap;

  @override
  State<NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<NavigationButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: kThemeAnimationDuration,
      vsync: this,
    )..addListener(() => setState(() {}));
    _animation = _animationController.view;

    if (widget.isActive) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NavigationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _animationController.reverse();
    }
    if (widget.isActive) {
      _animationController.forward();
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final indicator = NavigationIndicator(
      animation: _animation,
      color: widget.indicatorColor,
      width: widget.width,
    );
    final icon = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: widget.isActive ? widget.destination.selectedIcon : widget.destination.icon,
    );

    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: widget.onTap,
        onHover: (_) {},
        highlightShape: BoxShape.rectangle,
        borderRadius: null,
        containedInkWell: true,
        splashColor: colors.primary.withOpacity(0.12),
        hoverColor: colors.primary.withOpacity(0.04),
        child: Stack(
          alignment: Alignment.center,
          children: [indicator, icon],
        ),
      ),
    );
  }
}
