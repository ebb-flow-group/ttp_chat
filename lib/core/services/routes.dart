import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';

class Routes {
  static const String homeBrandRoute = '/home-brand/:id'; // Only for Main app
  static const String orderDetailRoute = '/orders/detail/:id';
  static const String orderScheduleRoute = '/orders/schedule/:id'; // Only for Creator app
  static const String orderTrackingLinkRoute = '/orders/tracking-link/:id'; // Only for Creator app
  static const String eventOrderDetailRoute = '/event-orders/detail/:id';
  static const String chatUserRoute = '/chats/user/:id';
  static const String userProfilePage = '/user/:id';

  static navigateToOutletPage(BuildContext context, String id) {
    context.push(RouteParser(Routes.homeBrandRoute).reverse({'id': Uri.encodeComponent(id)}));
  }

  static navigateToUserProfile(BuildContext context, String id) {
    //TODO : Uncomment when user profile is ready in main app
    // PR here : https://github.com/ebb-flow-group/tabletop_app_3/pull/130
    // context.push(RouteParser(Routes.userProfilePage).reverse({'id': Uri.encodeComponent(id)}));
  }
}
