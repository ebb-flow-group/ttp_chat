import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/chat_utils.dart';
import 'package:ttp_chat/packages/chat_types/src/message.dart';
import 'package:ttp_chat/theme/style.dart';

class OrderMessageWidget extends StatelessWidget {
  const OrderMessageWidget(
    this.message, {
    Key? key,
  }) : super(key: key);

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(2),
          color: ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text(
                ChatUtils().getOrderStatus(message.metadata!['status']),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey[300]!),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${message.metadata!['id']}',
                        style:
                            TextStyle(color: Theme.of(context).primaryColor, fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        height: 6.0,
                      ),
                      Row(
                        children: [
                          Text(
                            ChatUtils().getOrderDate(message.createdAt!),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            ' \u2022 ${message.metadata!['total_items']} items',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            ' \u2022 \$${message.metadata!['total_price_db']}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                          Text(
                            //TODO Show correct order type based on HomeOrder/HomeBrand, with old Order/Brand
                            //!https://www.notion.so/tabletophq/Take-Away-Pickup-rename-b9ce98007a5145c88853bcb8ad2817be?d=b8f06bdfb9024354bf33f5b54183f956
                            ' \u2022 ${ChatUtils().getOrderType(message.metadata)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            softWrap: true,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 26.0,
                      ),
                      GestureDetector(
                        onTap: () => context
                            .push(RouteParser('/orders/detail/:id').reverse({'id': "${message.metadata!['id']}"})),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icon/order_details.svg',
                                  package: 'ttp_chat',
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  'View Order Details',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor, fontSize: 14, fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
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
    );
  }
}
