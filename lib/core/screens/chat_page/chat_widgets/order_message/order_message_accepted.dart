import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
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
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

class OrderMessageAccepted extends StatelessWidget {
  final CustomMessage message;

  const OrderMessageAccepted({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCreatorApp = GetIt.I<ChatUtils>().isCreatorsApp;
    final hideActionButtons = !(message.metadata?['isLastMessageWithOrder'] == true);

    // For Creator app
    if (isCreatorApp) {
      return OrderMessageBox(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Nice! You’ve ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [
              TextSpan(text: 'accepted ', style: Ts.t2Bold(Config.successGreenColor)),
              TextSpan(text: 'Order ${message.metadata?['id']}', style: Ts.t3Bold(Config.primaryColor)),
            ],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'You can add a schedule so your customer knows when to expect the order.',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        ),
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
                if (message.metadata?['type'] == 'delivery' || message.metadata?['type'] == 'take_away')
                  AppButton(
                    text: 'Schedule',
                    onPressed: () {
                      if (message.metadata?['customer_preferred_start_date'] == null) {
                        context.push(message.orderDetailRoute!);
                        context.push(RouteParser(Routes.orderScheduleRoute)
                            .reverse({'id': message.metadata!['id']!.toString()}));
                      } else {
                        context.push('${message.orderDetailRoute!}?intent=schedule_order');
                      }
                    },
                    isDense: true,
                    isFullWidth: false,
                    bgColor: Config.creameryColor,
                    borderColor: Config.grayG4Color,
                    borderWidth: L.r(1),
                    textColor: Config.successGreenColor,
                    svg: Assets.lib.assets.calendar.svg(
                      color: Config.successGreenColor,
                      height: L.h(13),
                      width: L.w(11.7),
                    ),
                  ),
              ],
      );
    }

    // For Main app
    else {
      return OrderMessageBox(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Yay! Order ${message.metadata?['id']} has just been ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [TextSpan(text: 'ACCEPTED', style: Ts.t2Bold(Config.successGreenColor))],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'You can message ${message.brandName} if you’ve got anything to clarify.',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        ),
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
              ],
      );
    }
  }
}
