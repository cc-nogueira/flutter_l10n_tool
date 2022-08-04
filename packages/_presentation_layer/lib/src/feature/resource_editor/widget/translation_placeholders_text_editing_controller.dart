import 'package:_domain_layer/domain_layer.dart';
import 'package:flutter/material.dart';

import '../builder/arb_builder.dart';

class TranslationPlaceholdersTextEditingController extends TextEditingController {
  TranslationPlaceholdersTextEditingController(
      {String? text, required List<ArbPlaceholder> placeholders})
      : super(text: text) {
    _init(placeholders);
  }

  static final _placeholderNamesRegExp = RegExp(r'([\s\S]*?)({[a-zA-Z]\w*})');

  late final Set<String> validPlaceholders;
  late ArbBuilder arbBuilder;

  void _init(List<ArbPlaceholder> placeholders) {
    validPlaceholders = {
      for (final ph in placeholders) '{${ph.key}}',
    };
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final textSpan = super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );

    if (textSpan.children?.isEmpty ?? true) {
      return _textSpanForInput(text, style);
    }

    final children = <TextSpan>[];
    for (final span in textSpan.children!) {
      final textPart = span.toPlainText(includePlaceholders: false, includeSemanticsLabels: false);
      if (textPart.isEmpty) {
        continue;
      }
      children.add(_textSpanForInput(textPart, span.style));
    }
    return TextSpan(children: children);
  }

  TextSpan _textSpanForInput(String textPart, TextStyle? style) {
    final matches = _placeholderNamesRegExp.allMatches(textPart);
    if (matches.isEmpty) {
      return TextSpan(text: textPart, style: style);
    }
    final children = <InlineSpan>[];
    for (final match in matches) {
      if (match.group(1)!.isNotEmpty) {
        children.add(TextSpan(text: match.group(1)!, style: style));
      }
      final placeholder = match.group(2)!;
      final placeholderStyle = validPlaceholders.contains(placeholder)
          ? arbBuilder.optionStyle
          : arbBuilder.invalidOptionStyle;
      final mergedStyle = style?.merge(placeholderStyle) ?? placeholderStyle;
      children.add(TextSpan(text: placeholder, style: mergedStyle));
    }
    final idx = matches.last.end;
    if (idx < textPart.length) {
      children.add(TextSpan(text: textPart.substring(idx), style: style));
    }
    return TextSpan(children: children);
  }
}
