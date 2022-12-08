import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message_box.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/core/screens/widgets/app_button.dart';
import 'package:ttp_chat/core/services/extensions.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/routes.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/gen/assets.gen.dart';
import 'package:ttp_chat/network/api_service.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OrderMessageScheduled extends StatelessWidget {
  final CustomMessage message;

  const OrderMessageScheduled({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCreatorApp = GetIt.I<ChatUtils>().isCreatorsApp;

    // For Creator app
    if (isCreatorApp) {
      return _OrderMessageScheduledCreator(message: message);
    }

    // For Main app
    else {
      return _OrderMessageScheduledCustomer(message: message);
    }
  }
}

class _OrderMessageScheduledCreator extends StatelessWidget {
  final CustomMessage message;

  const _OrderMessageScheduledCreator({
    Key? key,
    required this.message,
  }) : super(key: key);

  RichText get _subtitle {
    DateTime? startDt = (message.metadata!['delivery_time_start'] as Timestamp?)?.toDate();
    DateTime? endDt = (message.metadata!['delivery_time_end'] as Timestamp?)?.toDate();

    if (startDt == null && endDt == null) {
      return RichText(text: const TextSpan(text: ''));
    }

    String prefix = '';
    if (message.metadata?['type'] == 'take_away') {
      prefix = 'This order will be picked up on';
    } else if (message.metadata?['type'] == 'delivery') {
      prefix = 'This order will be delivered on';
    }

    switch (message.metadata?['delivery_time_type']) {
      case 'daterange':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$prefix ${DateFormat('EEE dd MMM').format(startDt!)} - ${DateFormat('EEE dd MMM').format(endDt!)}',
            style: Ts.t3Semi(Config.grayG1Color),
          ),
        );
      case 'date':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$prefix ${DateFormat('EEE dd MMM').format(startDt!)}',
            style: Ts.t3Semi(Config.grayG1Color),
          ),
        );

      case 'datetime':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text:
                '$prefix ${DateFormat('EEE dd MMM').format(startDt!)}, ${DateFormat('hh:mm a').format(startDt)} - ${DateFormat('hh:mm a').format(endDt!)}',
            style: Ts.t3Semi(Config.grayG1Color),
          ),
        );

      default:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$prefix ${DateFormat('EEE dd MMM').format(startDt!)}',
            style: Ts.t3Semi(Config.grayG1Color),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderTypeStr = message.metadata?['type'] == 'delivery' ? 'delivery' : 'pickup';
    final hideActionButtons = !(message.metadata?['isLastMessageWithOrder'] == true);

    return OrderMessageBox(
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You’ve ',
          style: Ts.t3Bold(Config.primaryColor),
          children: [
            TextSpan(text: 'scheduled ', style: Ts.t2Bold(Config.successGreenColor)),
            TextSpan(text: 'Order ${message.metadata?['id']} for $orderTypeStr', style: Ts.t3Bold(Config.primaryColor)),
          ],
        ),
      ),
      subtitle: _subtitle,
      actions: hideActionButtons
          ? []
          : [
              AppButton(
                text: 'View Order',
                onPressed: () {
                  context.push(message.orderDetailRoute!);
                },
                isDense: true,
                isFullWidth: false,
                bgColor: Config.creameryColor,
                borderColor: Config.grayG4Color,
                borderWidth: L.r(1),
                textColor: Config.successGreenColor,
                svg: Assets.lib.assets.orders2.svg(color: Config.successGreenColor, height: L.h(12), width: L.w(12)),
              ),
              if (message.metadata?['tracking_url'] == null)
                AppButton(
                  text: 'Add Tracking Link',
                  onPressed: () {
                    context.push(RouteParser(Routes.orderTrackingLinkRoute)
                        .reverse({'id': message.metadata!['id']!.toString()}));
                  },
                  isDense: true,
                  isFullWidth: false,
                  bgColor: Config.creameryColor,
                  borderColor: Config.grayG4Color,
                  borderWidth: L.r(1),
                  textColor: Config.successGreenColor,
                  svg: Assets.lib.assets.truck.svg(color: Config.successGreenColor, height: L.h(12), width: L.w(13.33)),
                ),
              if (message.metadata?['tracking_url'] != null)
                AppButton(
                  text: 'Edit Tracking Link',
                  onPressed: () {
                    context.push(RouteParser(Routes.orderTrackingLinkRoute)
                        .reverse({'id': message.metadata!['id']!.toString()}));
                  },
                  isDense: true,
                  isFullWidth: false,
                  bgColor: Config.creameryColor,
                  borderColor: Config.grayG4Color,
                  borderWidth: L.r(1),
                  textColor: Config.successGreenColor,
                  svg: Assets.lib.assets.truck.svg(color: Config.successGreenColor, height: L.h(12), width: L.w(13.33)),
                ),
              AppButton(
                text: 'Mark as Fulfilled',
                onPressed: () async {
                  await ApiService().updateMyHomeOrder(
                    GetIt.I<ChatUtils>().accessToken!,
                    message.metadata!['id'],
                    {'status': 'pending_completion'},
                  );
                },
                isDense: true,
                isFullWidth: false,
                bgColor: Config.successGreenColor,
                textColor: Config.primaryColor,
                svg: Assets.lib.assets.tick.svg(color: Config.primaryColor, height: L.h(15), width: L.w(15)),
              ),
            ],
    );
  }
}

class _OrderMessageScheduledCustomer extends StatelessWidget {
  final CustomMessage message;

  const _OrderMessageScheduledCustomer({
    Key? key,
    required this.message,
  }) : super(key: key);

  RichText get _subtitle {
    DateTime? startDt = (message.metadata!['delivery_time_start'] as Timestamp?)?.toDate();
    DateTime? endDt = (message.metadata!['delivery_time_end'] as Timestamp?)?.toDate();

    if (startDt == null && endDt == null) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You can message ${message.brandName} if you’ve got anything to clarify.',
          style: Ts.t3Reg(Config.grayG1Color),
        ),
      );
    }

    String prefix = '';
    if (message.metadata?['type'] == 'take_away') {
      prefix = 'Your can pick up your order on';
    } else if (message.metadata?['type'] == 'delivery') {
      prefix = 'Your order will be delivered on';
    }

    switch (message.metadata?['delivery_time_type']) {
      case 'daterange':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$prefix ${DateFormat('EEE dd MMM').format(startDt!)} - ${DateFormat('EEE dd MMM').format(endDt!)}',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        );
      case 'date':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$prefix ${DateFormat('EEE dd MMM').format(startDt!)}',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        );

      case 'datetime':
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text:
                '$prefix ${DateFormat('EEE dd MMM').format(startDt!)}, ${DateFormat('hh:mm a').format(startDt)} - ${DateFormat('hh:mm a').format(endDt!)}',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        );

      default:
        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: '$prefix ${DateFormat('EEE dd MMM').format(startDt!)}',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideActionButtons = !(message.metadata?['isLastMessageWithOrder'] == true);

    return OrderMessageBox(
      title: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Order ${message.metadata?['id']} has been ',
          style: Ts.t3Bold(Config.primaryColor),
          children: [TextSpan(text: 'SCHEDULED', style: Ts.t2Bold(Config.successGreenColor))],
        ),
      ),
      subtitle: _subtitle,
      actions: hideActionButtons
          ? []
          : [
              AppButton(
                text: 'View Order',
                onPressed: () {
                  context.push(message.orderDetailRoute!);
                },
                isDense: true,
                isFullWidth: false,
                bgColor: Config.creameryColor,
                borderColor: Config.grayG4Color,
                borderWidth: L.r(1),
                textColor: Config.successGreenColor,
                svg: Assets.lib.assets.orders2.svg(color: Config.successGreenColor, height: L.h(12), width: L.w(12)),
              ),
              if (message.metadata!['tracking_url'] != null)
                AppButton(
                  text: 'Track Order',
                  onPressed: () {
                    final url = message.metadata!['tracking_url'];
                    if (url != null) {
                      launchUrlString(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  isDense: true,
                  isFullWidth: false,
                  bgColor: Config.creameryColor,
                  borderColor: Config.grayG4Color,
                  borderWidth: L.r(1),
                  textColor: Config.successGreenColor,
                  svg: Assets.lib.assets.truck.svg(color: Config.successGreenColor, height: L.h(12), width: L.w(13.33)),
                ),
            ],
    );
  }
}
