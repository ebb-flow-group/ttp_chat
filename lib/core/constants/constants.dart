import 'package:flutter/material.dart';
import 'package:ttp_chat/core/services/l.dart';

final kBaseSize = L.v(16);

final kScreenPaddingHor = EdgeInsets.symmetric(horizontal: kBaseSize);
final kScreenPaddingAll = EdgeInsets.symmetric(horizontal: kBaseSize, vertical: kBaseSize * 1.5);

final kDefaultShadow = BoxShadow(
  offset: const Offset(0, 0),
  blurRadius: 7,
  color: const Color(0xFFE9E9E9).withOpacity(0.56),
);
