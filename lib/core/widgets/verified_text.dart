import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ttp_chat/config.dart';

class VerifiedText extends StatelessWidget {
  final String text;
  final bool verified;
  final TextStyle style;
  final double iconSize;
  final EdgeInsets iconPadding;
  final Color iconColor;
  final int? maxLines;
  final TextAlign textAlign;

  const VerifiedText({
    Key? key,
    required this.text,
    required this.verified,
    required this.style,
    required this.iconSize,
    required this.iconPadding,
    this.iconColor = Config.successGreenColor,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  TextOverflow get _overflow {
    return maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: _overflow,
      text: TextSpan(
        children: [
          TextSpan(
            text: text,
            style: style,
          ),
          if (verified)
            WidgetSpan(
              child: Padding(
                padding: iconPadding,
                child: SvgPicture.asset(
                  'assets/icon/verified.svg',
                  color: iconColor,
                  height: iconSize,
                  width: iconSize,
                ),
              ),
              alignment: PlaceholderAlignment.middle,
            ),
        ],
      ),
    );
  }
}
