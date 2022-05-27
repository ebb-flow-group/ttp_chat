import 'dart:convert';

import '../../models/brand.dart';

extension DecodeExtensions on String? {
  Brand? toBrand() {
    return this == null ? null : Brand.fromJson(jsonDecode(this!));
  }
}
