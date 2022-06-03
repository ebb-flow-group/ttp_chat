import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';

class Routes {
  static const String homeOutletPage = '/home-brand/:id';
  static const String orderDetailRoute = '/orders/detail/:id';
  static const String orderPaymentRoute = '/orders/pay/:id';
  static const String ordersRoute = '/orders';
  static const String chatUserRoute = '/chats/user/:id';
  static const String userProfilePage = '/user/:id';

  static navigateToOutletPage(BuildContext context, String id) {
    context.push(RouteParser(Routes.homeOutletPage).reverse({'id': Uri.encodeComponent(id)}));
  }
}
