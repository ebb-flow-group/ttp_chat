import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../theme/style.dart';

class StartChatMessage extends StatelessWidget {
  final void Function()? goToSearch;
  const StartChatMessage({this.goToSearch, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/chat_icons/start_chat.svg',
            width: 34,
            height: 34,
          ),
          const SizedBox(height: 20),
          Text(
            'Connect with the community',
            style: appBarTitleStyle(context).copyWith(fontSize: 22),
          ),
          const SizedBox(height: 12),
          const Text(
            'Thriving communities are made up of vibrant connections. Chat makes it personal, putting you in direct contact with your fans and customers.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
              icon: Icon(
                Icons.add_rounded,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              label: Text(
                'Start Your First Chat',
                style: appBarTitleStyle(context).copyWith(fontSize: 14),
              ),
              onPressed: goToSearch)
        ],
      ),
    );
  }
}
