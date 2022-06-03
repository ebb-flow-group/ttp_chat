import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/core/services/ts.dart';

import '../../../config.dart';

class LastMessaageWidget extends StatelessWidget {
  final Map data;
  const LastMessaageWidget(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isNotEmpty) {
      if (data['type'] == 'image') {
        return Row(
          children: [
            Icon(
              Icons.image,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'Image',
              style: Ts.text14(Config.grayG1Color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else if (data['type'] == 'file') {
        return Row(
          children: [
            Icon(
              Icons.file_present,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              'File',
              style: Ts.text14(Config.grayG1Color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else if (data['type'] == 'voice') {
        return Row(
          children: [
            Icon(
              Icons.mic,
              color: Theme.of(context).primaryColor,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'Voice message',
              style: Ts.text14(Config.grayG1Color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else if (data['type'] == 'custom') {
        return Row(
          children: [
            SvgPicture.asset(
              'assets/chat_icons/order_history.svg',
              width: 14,
              height: 14,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              'Order',
              style: Ts.text14(Config.grayG1Color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else if (data['type'] == 'text') {
        return Text(
          data['text'],
          style: Ts.text14(Config.grayG1Color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    return const SizedBox();
  }
}
