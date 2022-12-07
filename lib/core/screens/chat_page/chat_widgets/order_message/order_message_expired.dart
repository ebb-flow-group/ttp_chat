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

class OrderMessageExpired extends StatelessWidget {
  final CustomMessage message;

  const OrderMessageExpired({Key? key, required this.message}) : super(key: key);

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
            text: 'You’ve ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [
              TextSpan(text: 'disputed ', style: Ts.t2Bold(Config.mentaikoColor)),
              TextSpan(text: 'Order ${message.metadata?['id']}', style: Ts.t2Reg(Config.primaryColor)),
            ],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text:
                'Something might not have gone according to plan? Reach out to your customer to find out what and see if a resolution can be worked out. Or reach out to Tabletop Support if you need help.',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        ),
        actions: [
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
          AppButton(
            text: 'Tabletop Support',
            onPressed: () {
              context.push(RouteParser(Routes.chatUserRoute).reverse({'id': 'tabletopsupport'}));
            },
            isDense: true,
            isFullWidth: false,
            bgColor: Config.creameryColor,
            borderColor: Config.grayG4Color,
            borderWidth: L.r(1),
            textColor: Config.successGreenColor,
            svg: Assets.lib.assets.headphone.svg(color: Config.successGreenColor, height: L.h(12), width: L.w(15.44)),
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
            text: 'You’ve ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [
              TextSpan(text: 'DISPUTED ', style: Ts.t2Bold(Config.mentaikoColor)),
              TextSpan(text: 'Order ${message.metadata?['id']}', style: Ts.t2Reg(Config.primaryColor)),
            ],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text:
                'Something went wrong with your order? You can find a resolution with ${message.brandName}, or reach out to Tabletop Support if you need help.',
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
                AppButton(
                  text: 'Support',
                  onPressed: () {
                    context.push(RouteParser(Routes.chatUserRoute).reverse({'id': 'tabletopsupport'}));
                  },
                  isDense: true,
                  isFullWidth: false,
                  bgColor: Config.creameryColor,
                  borderColor: Config.grayG4Color,
                  borderWidth: L.r(1),
                  textColor: Config.successGreenColor,
                  svg: Assets.lib.assets.headphone
                      .svg(color: Config.successGreenColor, height: L.h(12), width: L.w(15.44)),
                ),
              ],
      );
    }
  }
}
