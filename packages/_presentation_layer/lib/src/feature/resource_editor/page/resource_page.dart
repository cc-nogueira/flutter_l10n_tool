import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widget/message_widget.dart';
import '../../../l10n/app_localizations.dart';
import '../../../provider/presentation_providers.dart';
import '../widget/definition_widget.dart';
import '../widget/resource_bar.dart';
import '../widget/translation_widget.dart';

class ResourcePage extends ConsumerWidget {
  const ResourcePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(editNewDefinitionProvider)) {
      return _NewResourcePage();
    }
    final originalDefinition = ref.watch(selectedDefinitionProvider);
    if (originalDefinition == null) {
      return const _NoResouceSelectedPage();
    }
    return _ResourcePage(originalDefinition);
  }
}

class _ResourcePage<D extends ArbDefinition> extends ConsumerWidget with _NewResourceMixin {
  const _ResourcePage(this.originalDefinition);

  final D originalDefinition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDefinition =
        ref.watch(currentDefinitionsProvider.select((value) => value[originalDefinition])) as D?;
    final selectedTranslations = ref.watch(selectedLocaleTranslationsProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResourceBar(),
            DefinitionWidget<D>(original: originalDefinition, current: currentDefinition),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 72),
                shrinkWrap: false,
                itemBuilder: (_, idx) =>
                    _itemBuilder(originalDefinition, currentDefinition, selectedTranslations[idx]),
                itemCount: selectedTranslations.length,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _fab(ref.read),
    );
  }

  Widget? _fab(Reader read) => FloatingActionButton(
        onPressed: () => newResourceDefinition(read),
        child: const Icon(Icons.add),
      );

  Widget _itemBuilder(
    ArbDefinition originalDefinition,
    ArbDefinition? currentDefinition,
    ArbLocaleTranslations localeTranslations,
  ) =>
      originalDefinition.map(
        placeholders: (original) => PlaceholdersTranslationWidget(
          localeTranslations.locale,
          originalDefinition: original,
          currentDefinition: currentDefinition as ArbPlaceholdersDefinition?,
          originalTranslation: localeTranslations.translations[originalDefinition.key]
              as ArbPlaceholdersTranslation?,
        ),
        plural: (original) => PluralTranslationWidget(
          localeTranslations.locale,
          originalDefinition: original,
          currentDefinition: currentDefinition as ArbPluralDefinition?,
          originalTranslation:
              localeTranslations.translations[originalDefinition.key] as ArbPluralTranslation?,
        ),
        select: (original) => SelectTranslationWidget(localeTranslations.locale,
            originalDefinition: original,
            currentDefinition: currentDefinition as ArbSelectDefinition?,
            originalTranslation:
                localeTranslations.translations[originalDefinition.key] as ArbSelectTranslation?),
      );
}

class _NewResourcePage extends StatefulWidget {
  @override
  State<_NewResourcePage> createState() => _NewResourcePageState();
}

class _NewResourcePageState extends State<_NewResourcePage> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late CurvedAnimation _moveAnimation;
  late CurvedAnimation _iconOpacityAnimation;
  late CurvedAnimation _containerOpacityAnimation;

  static const kFlightAnimationDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kFlightAnimationDuration);
    _configAnimations();
    _resetState();
  }

  void _configAnimations() {
    const transitionStart = 0.6;
    _moveAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, transitionStart),
    );
    _iconOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(transitionStart / 2.0, transitionStart),
    );
    _containerOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(transitionStart, 1.0),
    );
  }

  void _resetState() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedNewResourcePage(
      _controller,
      moveAnimation: _moveAnimation,
      iconOpacityAnimation: _iconOpacityAnimation,
      containerOpacityAnimation: _containerOpacityAnimation,
    );
  }
}

class _AnimatedNewResourcePage extends AnimatedWidget {
  _AnimatedNewResourcePage(
    AnimationController animation, {
    required this.moveAnimation,
    required this.iconOpacityAnimation,
    required this.containerOpacityAnimation,
  }) : super(listenable: animation);

  final CurvedAnimation moveAnimation;
  final CurvedAnimation iconOpacityAnimation;
  final CurvedAnimation containerOpacityAnimation;

  final StateController<Offset> startTargetOffset = StateController(Offset.zero);
  final StateController<Offset> finalTargetOffset = StateController(Offset.zero);
  final StateController<RenderBox?> startTargetRenderBox = StateController(null);
  final StateController<RenderBox?> finalTargetRenderBox = StateController(null);

  final _stackKey = LabeledGlobalKey('newResourceStackKey');
  final _addButtonKey = LabeledGlobalKey('addButtonKey');
  final _formContainerKey = LabeledGlobalKey('formContainerKey');

  Animation<double> get animation => listenable as Animation<double>;
  AnimationController get controller => listenable as AnimationController;

  bool get isInitial => animation.value == 0.0;
  bool get isAnimating => animation.value > 0.0 && animation.value < 1.0;
  bool get isFinal => animation.value == 1.0;

  @override
  Widget build(BuildContext context) {
    if (isInitial) {
      startTargetRenderBox.state = null;
    }
    if (isFinal) {
      finalTargetRenderBox.state = null;
    }
    return Stack(
      key: _stackKey,
      children: [
        _page(),
        _transitioningButton(),
      ],
    );
  }

  Widget _page() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ResourceBar(),
            Opacity(
              opacity: containerOpacityAnimation.value > 0 ? 1.0 : 0.0,
              child: NewDefinitionWidget(key: _formContainerKey, onDone: _onDone),
            ),
          ],
        ),
      ),
      floatingActionButton: isInitial
          ? FloatingActionButton(
              key: _addButtonKey,
              onPressed: () => {},
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _onDone() async => controller.reverse(from: 1.0);

  Widget _transitioningButton() {
    if (isAnimating) {
      if (startTargetRenderBox.state == null) {
        _readStartPosition();
      }
      if (finalTargetRenderBox.state == null) {
        _readFinalPosition();
      }
    }
    if (!isAnimating || startTargetRenderBox.state == null || finalTargetRenderBox.state == null) {
      return Container();
    }

    final startSize = startTargetRenderBox.state!.size;
    final finalSize = finalTargetRenderBox.state!.size;
    final sizeDiff = (finalSize - startSize) as Offset;
    final startOffset = startTargetOffset.state;
    final finalOffset = finalTargetOffset.state;
    final dist = finalOffset - startOffset;

    return Positioned(
        top: startOffset.dy + moveAnimation.value * dist.dy,
        left: startOffset.dx + moveAnimation.value * dist.dx,
        child: SizedBox(
          width: startSize.width + moveAnimation.value * sizeDiff.dx,
          height: startSize.height + moveAnimation.value * sizeDiff.dy,
          child: _flightWidget(),
        ));
  }

  Widget _flightWidget() {
    final iconOpacity = 1.0 - iconOpacityAnimation.value;
    final containerOpacity = 1.0 - containerOpacityAnimation.value;
    return Opacity(
      opacity: containerOpacity,
      child: FloatingActionButton(
        heroTag: null,
        child: Opacity(
          opacity: iconOpacity,
          child: const Icon(Icons.add),
        ),
        onPressed: () {},
      ),
    );
  }

  void _readStartPosition() {
    final startTarget = _addButtonKey.currentContext?.findRenderObject();
    final stackWidget = _stackKey.currentContext?.findRenderObject();
    if (startTarget is RenderBox && stackWidget != null) {
      startTargetRenderBox.state = startTarget;
      startTargetOffset.state = startTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
    }
  }

  void _readFinalPosition() {
    final finalTarget = _formContainerKey.currentContext?.findRenderObject();
    final stackWidget = _stackKey.currentContext?.findRenderObject();
    if (finalTarget is RenderBox && stackWidget != null) {
      finalTargetRenderBox.state = finalTarget;
      finalTargetOffset.state = finalTarget.localToGlobal(Offset.zero, ancestor: stackWidget);
    }
  }
}

class _NoResouceSelectedPage extends ConsumerWidget with _NewResourceMixin {
  const _NoResouceSelectedPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Padding(padding: const EdgeInsets.all(8.0), child: _noResourceSelected(context, loc)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => newResourceDefinition(ref.read),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _noResourceSelected(BuildContext context, AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        ResourceBar(),
        Expanded(child: MessageWidget('No resource selected')),
      ],
    );
  }
}

mixin _NewResourceMixin {
  void newResourceDefinition(Reader read) {
    final arbUsecase = read(arbUsecaseProvider);
    arbUsecase.editNewDefinition();
  }
}
