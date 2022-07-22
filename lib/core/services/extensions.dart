import 'dart:convert';

import 'package:intl/intl.dart';

import '../../models/brand_model.dart';

extension DecodeExtensions on String? {
  Brand? get toBrand {
    return this == null ? null : Brand.fromJson(jsonDecode(this!));
  }
}

extension NumberPriceFormatter on num? {
  String toPriceStr(String? currency) {
    if (this == null) return '0';

    return NumberFormat.simpleCurrency(name: currency).format(this);
  }
}

extension StringPriceFormatter on String? {
  String toPriceStr(String? currency) {
    if (this == null) return '0';

    final number = double.tryParse(this!);

    if (number == null) {
      return this!;
    }

    return NumberFormat.simpleCurrency(name: currency).format(number);
  }
}
