import 'dart:convert';

import '../../models/brand_model.dart';

extension DecodeExtensions on String? {
  Brand? get toBrand {
    return this == null ? null : Brand.fromJson(jsonDecode(this!));
  }
}
