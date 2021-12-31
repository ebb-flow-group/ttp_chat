import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/theme/style.dart';

class NoResults extends StatelessWidget {
  const NoResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/chat_icons/no_chat_user.svg',
            width: 20,
            height: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'No result',
            style: appBarTitleStyle(context).copyWith(fontSize: 16),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
