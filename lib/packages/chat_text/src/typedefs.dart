import 'package:flutter/material.dart';

typedef HighlightStyle = TextStyle? Function(
  TextStyle baseStyle,
  String text,
  int index,
);

typedef TapCallback = void Function(
  String text,
  int index,
);
