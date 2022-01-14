import 'package:flutter/material.dart';

class BottomSheetItem extends StatelessWidget {
  final Widget? leading;
  final Text? title;
  final Function()? onTap;
  final bool? showDivider;

  const BottomSheetItem({
    Key? key,
    this.leading,
    this.title,
    this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  TextStyle _titleTextStyle(ThemeData theme) {
    return theme.textTheme.bodyText2!.copyWith(
      fontWeight: FontWeight.w600,
      color: onTap != null ? theme.primaryColor : theme.disabledColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    TextStyle titleTextStyle = _titleTextStyle(theme);
    final Widget titleText = AnimatedDefaultTextStyle(
      style: titleTextStyle,
      duration: kThemeChangeDuration,
      child: title ?? Container(),
    );
    return GestureDetector(
      onTap: onTap!,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: leading,
                ),
                const SizedBox(width: 20),
                titleText,
              ],
            ),
          ),
          showDivider! ? const Divider(indent: 50, endIndent: 20) : Container(),
        ],
      ),
    );
  }
}
