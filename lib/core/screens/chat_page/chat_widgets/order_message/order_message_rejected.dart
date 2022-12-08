import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message_box.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/core/screens/widgets/app_button.dart';
import 'package:ttp_chat/core/services/extensions.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/gen/assets.gen.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

class OrderMessageRejected extends StatelessWidget {
  final CustomMessage message;

  const OrderMessageRejected({Key? key, required this.message}) : super(key: key);

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
            text: 'You ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [
              TextSpan(text: 'rejected ', style: Ts.t2Bold(Config.mustard2)),
              TextSpan(text: 'Order ${message.metadata?['id']}', style: Ts.t3Bold(Config.primaryColor)),
            ],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Let your customer know why and perhaps make suggestions for a new order.',
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

    // For Main app
    else {
      return OrderMessageBox(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Hmm.. Order ${message.metadata?['id']} was ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [TextSpan(text: 'REJECTED', style: Ts.t2Bold(Config.mustard2))],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text:
                'You’ll be fully refunded for this order. You could message ${message.brandName} to find out why it was rejected.',
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
