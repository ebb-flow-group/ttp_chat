import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_text/src/typedefs.dart';

class ChatText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final HighlightStyle? highlightStyle;
  final TapCallback? onPressed;
  final RegExp? highlightRegex;

  const ChatText({
    Key? key,
    required this.text,
    this.style,
    this.highlightStyle,
    this.onPressed,
    this.highlightRegex,
  }) : super(key: key);

  TextSpan _highlightSpan(String content, int index) {
    if (highlightStyle == null) return TextSpan(text: content);
    return TextSpan(
      text: content,
      style: highlightStyle!(style!, content, index),
      recognizer: TapGestureRecognizer()..onTap = () => onPressed?.call(content, index),
    );
  }

  TextSpan _normalSpan(String content) {
    return TextSpan(text: content);
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return Text('', style: style);
    }

    if (highlightRegex == null) {
      return Text(text, style: style);
    }

    List<TextSpan> spans = [];
    int start = 0;
    while (true) {
      final String? highlight = highlightRegex!.stringMatch(text.substring(start));
      if (highlight == null) {
        // no highlight
        spans.add(_normalSpan(text.substring(start)));
        break;
      }

      final int indexOfHighlight = text.indexOf(highlight, start);

      if (indexOfHighlight == start) {
        // starts with highlight
        spans.add(_highlightSpan(highlight, indexOfHighlight));
        start += highlight.length;
      } else {
        // normal + highlight
        spans.add(_normalSpan(text.substring(start, indexOfHighlight)));
        spans.add(_highlightSpan(highlight, indexOfHighlight));
        start = indexOfHighlight + highlight.length;
      }
    }

    return SelectableText.rich(
      TextSpan(
        style: style,
        children: spans,
      ),
      scrollPhysics: const NeverScrollableScrollPhysics(),
    );
  }
}
