import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/order_message_box.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/core/screens/widgets/app_button.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/core/services/routes.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/gen/assets.gen.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart';

class OrderMessageCancelled extends StatelessWidget {
  final CustomMessage message;

  const OrderMessageCancelled({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCreatorApp = GetIt.I<ChatUtils>().isCreatorsApp;

    // For Creator app
    if (isCreatorApp) {
      return _OrderMessageDisputedCreator(message: message);
    }

    // For Main app
    else {
      return _OrderMessageDisputedCustomer(message: message);
    }
  }
}

class _OrderMessageDisputedCreator extends StatelessWidget {
  final CustomMessage message;

  const _OrderMessageDisputedCreator({
    Key? key,
    required this.message,
  }) : super(key: key);

  bool get _isOrderCancelledByCreator => message.metadata?['cancelled_by_user'] == false;

  RichText get _title {
    if (_isOrderCancelledByCreator) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You ',
          style: Ts.t3Bold(Config.primaryColor),
          children: [
            TextSpan(text: 'cancelled ', style: Ts.t2Bold(Config.mentaikoColor)),
            TextSpan(text: 'and refunded Order ${message.metadata?['id']}'),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Order ${message.metadata?['id']} was ',
          style: Ts.t3Bold(Config.primaryColor),
          children: [
            TextSpan(text: 'cancelled ', style: Ts.t2Bold(Config.mentaikoColor)),
            const TextSpan(text: 'and refunded'),
          ],
        ),
      );
    }
  }

  RichText get _subtitle {
    if (_isOrderCancelledByCreator) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You cancelled this order and will be ',
          style: Ts.t3Reg(Config.grayG1Color),
          children: [
            TextSpan(text: 'refunded in full. ', style: Ts.t3Bold(Config.grayG1Color)),
            const TextSpan(
              text: 'Check with your customer if you’ve got anything to clarify, or reach out to us for help.',
            ),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Your customer cancelled your order. A ',
          style: Ts.t3Reg(Config.grayG1Color),
          children: [
            TextSpan(text: 'full refund will be processed. ', style: Ts.t3Bold(Config.grayG1Color)),
            const TextSpan(text: 'Inform your customer if there’s anything of note, or reach out to us for help.'),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideActionButtons = !(message.metadata?['isLastMessageWithOrder'] == true);

    return OrderMessageBox(
      title: _title,
      subtitle: _subtitle,
      actions: hideActionButtons
          ? []
          : [
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
                svg: Assets.lib.assets.headphone
                    .svg(color: Config.successGreenColor, height: L.h(12), width: L.w(15.44)),
              ),
            ],
    );
  }
}

class _OrderMessageDisputedCustomer extends StatelessWidget {
  final CustomMessage message;

  const _OrderMessageDisputedCustomer({
    Key? key,
    required this.message,
  }) : super(key: key);

  bool get _isOrderCancelledByCustomer => message.metadata?['cancelled_by_user'] == true;

  RichText get _title {
    if (_isOrderCancelledByCustomer) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You ',
          style: Ts.t3Bold(Config.primaryColor),
          children: [
            TextSpan(text: 'cancelled ', style: Ts.t2Bold(Config.mentaikoColor)),
            TextSpan(text: 'Order ${message.metadata?['id']} and will be refunded'),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'Order ${message.metadata?['id']} was ',
          style: Ts.t3Bold(Config.primaryColor),
          children: [
            TextSpan(text: 'cancelled ', style: Ts.t2Bold(Config.mentaikoColor)),
            const TextSpan(text: 'and refunded'),
          ],
        ),
      );
    }
  }

  RichText get _subtitle {
    if (_isOrderCancelledByCustomer) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: 'You cancelled this order and will be ',
          style: Ts.t3Reg(Config.grayG1Color),
          children: [
            TextSpan(text: 'refunded in full. ', style: Ts.t3Bold(Config.grayG1Color)),
            TextSpan(
              text: 'Check with ${message.brandName} if you’ve got anything to clarify, or reach out to us for help.',
            ),
          ],
        ),
      );
    } else {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '${message.brandName} cancelled your order. You’ll be ',
          style: Ts.t3Reg(Config.grayG1Color),
          children: [
            TextSpan(text: 'refunded in full. ', style: Ts.t3Bold(Config.grayG1Color)),
            const TextSpan(
              text: 'Have something to clarify? Check with them via chat, or reach out to us for help.',
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hideActionButtons = !(message.metadata?['isLastMessageWithOrder'] == true);

    return OrderMessageBox(
      title: _title,
      subtitle: _subtitle,
      actions: hideActionButtons
          ? []
          : [
              AppButton(
                text: 'Reorder',
                onPressed: () {
                  context
                      .push(RouteParser(Routes.homeBrandRoute).reverse({'id': message.metadata!['brand']!.toString()}));
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
                svg: Assets.lib.assets.headphone
                    .svg(color: Config.successGreenColor, height: L.h(12), width: L.w(15.44)),
              ),
            ],
    );
  }
}
