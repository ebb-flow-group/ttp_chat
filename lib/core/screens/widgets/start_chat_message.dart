import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/core/services/ts.dart';

import '../../../config.dart';

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
            width: 30,
            height: 30,
          ),
          const SizedBox(height: 20),
          Text(
            'Connect with the community',
            style: Ts.bold20(Config.primaryColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Thriving communities are made up of vibrant connections. Chat makes it personal, putting you in direct contact with your fans and customers.',
            style: Ts.text14(Config.grayG1Color),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
              icon: Icon(
                Icons.add_rounded,
                color: Theme.of(context).primaryColor,
                size: 10,
              ),
              label: Text(
                'Start Your First Chat',
                style: Ts.bold14(Config.primaryColor),
              ),
              onPressed: goToSearch)
        ],
      ),
    );
  }
}
