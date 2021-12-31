import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
            const Text(
              'Image',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
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
            const Text(
              'File',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
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
            const Text(
              'Voice message',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
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
            const Text(
              'Order',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      } else if (data['type'] == 'text') {
        return Text(
          data['text'],
          style: const TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      }
    }

    return const SizedBox();
  }
}
