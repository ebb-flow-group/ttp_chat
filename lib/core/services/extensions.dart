import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/core/services/routes.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

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

extension OrderMessage on CustomMessage {

  /// Return event booking route if message is event booking
  /// Else return order detail route if message is home order
  String? get orderDetailRoute {
    if (metadata?['id'] == null || metadata?['type'] == null) return null;

    if (metadata!['type'] == 'event') {
      return RouteParser(Routes.eventOrderDetailRoute).reverse({'id': metadata!['id']!.toString()});
    } else if (metadata!['type'] == 'delivery' || metadata!['type'] == 'take_away') {
      return RouteParser(Routes.orderDetailRoute).reverse({'id': metadata!['id']!.toString()});
    }

    return null;
  }
}
