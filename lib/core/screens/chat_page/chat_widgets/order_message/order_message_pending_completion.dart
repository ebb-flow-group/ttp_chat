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
import 'package:ttp_chat/network/api_service.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

class OrderMessagePendingCompletion extends StatelessWidget {
  final CustomMessage message;

  const OrderMessagePendingCompletion({Key? key, required this.message}) : super(key: key);

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
            text: 'You’ve marked Order ${message.metadata?['id']} as ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [TextSpan(text: 'fulfilled', style: Ts.t2Bold(Config.successGreenColor))],
          ),
        ),
        subtitle: null,
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
        ],
      );
    }

    // For Main app
    else {
      return OrderMessageBox(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'Order ${message.metadata?['id']} has been ',
            style: Ts.t3Bold(Config.primaryColor),
            children: [TextSpan(text: 'FULFILLED', style: Ts.t2Bold(Config.successGreenColor))],
          ),
        ),
        subtitle: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text:
                'Mark as received to indicate that you’ve gotten your order. Otherwise, it’ll be considered complete in 48 hours.',
            style: Ts.t3Reg(Config.grayG1Color),
          ),
        ),
        actions: hideActionButtons
            ? []
            : [
                AppButton(
                  text: 'Mark as Received',
                  onPressed: () async {
                    await ApiService().updateHomeOrder(
                      GetIt.I<ChatUtils>().accessToken!,
                      message.metadata!['id'],
                      {'status': 'completed'},
                    );
                  },
                  isDense: true,
                  isFullWidth: false,
                  bgColor: Config.creameryColor,
                  borderColor: Config.grayG4Color,
                  borderWidth: L.r(1),
                  textColor: Config.successGreenColor,
                  svg: Assets.lib.assets.tick.svg(color: Config.successGreenColor, height: L.h(15), width: L.w(15)),
                ),
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
