class Routes {
  static const String routePrefix = '/t';

  static const String homeOutletDetailPage = '$routePrefix/home-brand';
  static const String orderDetailRoute = '$routePrefix/orders/detail/:id';
  static const String orderPaymentRoute = '$routePrefix/orders/pay/:id';
  static const String ordersRoute = '$routePrefix/orders';
  static const String chatUserRoute = '$routePrefix/chats/user/:id';
  static const String userProfilePage = '$routePrefix/user/:id';
}
