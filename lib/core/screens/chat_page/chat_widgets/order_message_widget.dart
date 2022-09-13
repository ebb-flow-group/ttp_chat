import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/core/services/extensions.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/src/message.dart';

import '../../../../config.dart';
import '../../../services/routes.dart';
import '../../widgets/helpers.dart';
import 'models/color_model.dart';

class OrderMessageWidget extends StatelessWidget {
  const OrderMessageWidget(
    this.message, {
    Key? key,
  }) : super(key: key);

  final Message message;

  String get totalPrice {
    if (message.metadata?['total_price_db'] == null || message.metadata?['total_price_db'] == 'None') {
      return "${message.metadata?['base_price_db']}".toPriceStr(message.metadata?['currency']);
    }
    return "${message.metadata?['total_price_db']}".toPriceStr(message.metadata?['currency']);
  }

  String get orderStatus => getOrderStatus(message.metadata?['status']).toUpperCase();

  bool get checkedOut => message.metadata?['status'] == 'checked_out';

  bool get paymentPending => message.metadata?['status'] == "checked_out" && !GetIt.I.get<ChatUtils>().isCreatorsApp;

  bool get isCreatorsApp => GetIt.I.get<ChatUtils>().isCreatorsApp;

  TextColor get statusColor => getStatusBannerColor(orderStatus);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Config.creameryColor,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Config.grayG4Color),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.bgColor),
                    child: Text(
                      orderStatus,
                      style: Ts.bold10(statusColor.textColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    getLastMessageDateTime({"createdAt": message.createdAt}),
                    style: Ts.demi11(Config.grayG1Color),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Config.grayG5Color, height: 0),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ${message.metadata?['id']}',
                          style: Ts.bold15(Config.primaryColor),
                        ),
                        Row(
                          children: [
                            Text(
                              getOrderDate(message.createdAt!),
                              style: Ts.demi11(Config.grayG1Color),
                              softWrap: true,
                            ),
                            Text(
                              ' \u2022 ${message.metadata?['total_items']} items',
                              style: Ts.demi11(Config.grayG1Color),
                              softWrap: true,
                            ),
                            Text(
                              ' \u2022 $totalPrice',
                              style: Ts.demi11(Config.grayG1Color),
                              softWrap: true,
                            ),
                            Text(
                              ' \u2022 ${getOrderType(message.metadata)}',
                              style: Ts.demi11(Config.grayG1Color),
                              softWrap: true,
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(color: Config.grayG5Color, height: 0),
                        ),
                        GestureDetector(
                          onTap: () {
                            String? orderId = message.metadata?['id']?.toString();
                            if (orderId == null) return;

                            if (message.metadata?["type"] == "event") {
                              context.push(RouteParser(Routes.eventOrderDetailRoute).reverse({'id': orderId}));
                            } else {
                              context.push(RouteParser(Routes.orderDetailRoute).reverse({'id': orderId}));
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: paymentPending ? Config.mentaikoColor : Config.grayG4Color)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    paymentPending ? 'assets/icon/payment.svg' : 'assets/icon/order_details.svg',
                                    package: 'ttp_chat',
                                    color: paymentPending ? Config.mentaikoColor : Theme.of(context).primaryColor,
                                    width: 13,
                                    height: 13,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    getButtonText(message.metadata?['status']),
                                    style: Ts.bold11(paymentPending ? Config.mentaikoColor : Config.primaryColor),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String getButtonText(String status) {
    bool isCreatorsApp = GetIt.I<ChatUtils>().isCreatorsApp;
    String btnText = 'View Order';

    switch (status) {
      case 'checked_out':
        return isCreatorsApp ? btnText : 'Go to Payment ';
      case 'pending_completion':
        return isCreatorsApp ? btnText : 'Mark as Received';
      case 'expired':
        return isCreatorsApp ? btnText : 'View to Reorder';
      default:
        return btnText;
    }
  }

  static String getOrderStatus(String status) {
    bool isCreatorsApp = GetIt.I<ChatUtils>().isCreatorsApp;
    switch (status) {
      case 'paid':
        return isCreatorsApp ? 'NEW' : 'PENDING';
      case 'checked_out':
        return 'UNPAID';
      case 'failed':
        return 'FAILED';
      case 'rejected':
        return 'REJECTED';
      case 'accepted':
        return 'ACCEPTED';
      case 'scheduled':
        return 'SCHEDULED';
      case 'pending_completion':
        return 'FULFILLED';
      case 'completed':
        return 'COMPLETED';
      case 'dispute':
        return 'DISPUTED';
      case 'expired':
        return 'EXPIRED';
      default:
        return '';
    }
  }

  static String getOrderType(Map<String, dynamic>? metadata) {
    if (metadata == null) return "";
    String orderType = metadata['type'];
    if (metadata["message_type"] == "home_order_update" || metadata["message_type"] == "home_order_create") {
      switch (orderType) {
        case 'pick_up':
          return 'Pickup';
        case 'take_away':
          return 'Pickup';
        case 'dine_in':
          return 'Dine In';
        case 'delivery':
          return 'Delivery';
        default:
          return '';
      }
    } else {
      switch (orderType) {
        case 'pick_up':
          return 'Pickup';
        case 'take_away':
          return 'Take Away';
        case 'dine_in':
          return 'Dine In';
        case 'delivery':
          return 'Delivery';
        default:
          return '';
      }
    }
  }

  static TextColor getStatusBannerColor(String status) {
    TextColor color = TextColor();
    switch (status) {
      case 'UNPAID':
        return color..bgColor = Config.mentaikoColor;
      case 'FAILED':
        return TextColor(bgColor: Config.lightGrey, textColor: Config.mentaikoColor);
      case 'PENDING':
        return TextColor(bgColor: Config.yellowColor, textColor: Config.primaryColor);
      case 'REJECTED':
        return TextColor(bgColor: Config.lightGrey, textColor: Config.mentaikoColor);
      case 'ACCEPTED':
        return color..bgColor = Config.successColor;
      case 'COMPLETED':
        return TextColor(bgColor: Config.lightGrey, textColor: Config.grayG1Color);
      case 'DISPUTED':
        return TextColor(bgColor: Config.lightGrey, textColor: Config.mentaikoColor);
      case 'FULFILLED':
        return TextColor(bgColor: Config.lightGrey, textColor: Config.successColor);
      case 'EXPIRED':
        return TextColor(bgColor: Config.lightGrey, textColor: Config.mentaikoColor);
      default:
        return color;
    }
  }

  String getOrderDate(int orderDate) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(orderDate);

    if (date == DateTime.now()) {
      return 'Today';
    } else if (date.isBefore(DateTime.now())) {
      return DateFormat('dd MMM').format(date);
    } else {
      return '';
    }
  }
}
