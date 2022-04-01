import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/core/screens/widgets/helpers.dart';

import '../../../../config.dart';
import '../../../../features/chat/domain/search_user_model.dart';
import '../../../../utils/functions.dart';

class SearchUserTile extends StatelessWidget {
  const SearchUserTile({Key? key, required this.singleUser, this.onChatClick}) : super(key: key);

  final Users singleUser;
  final void Function()? onChatClick;

  @override
  Widget build(BuildContext context) {
    return isLoggedInUser(singleUser.phoneNumber)
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.5),
            child: Row(
              children: [
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.grey[200], gradient: Config.tabletopGradient),
                    child: Center(
                        child: Text(getInitials('${singleUser.firstName ?? ""} ${singleUser.lastName ?? ""}'),
                            style: const TextStyle(color: Colors.white)))),
                const SizedBox(width: 17),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              singleUser.firstName != null && singleUser.lastName != null
                                  ? '${singleUser.firstName!} ${singleUser.lastName!}'
                                  : 'Guest',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Text(
                            //   singleUser.email != null
                            //       ? singleUser.email!
                            //       : singleUser.phoneNumber!,
                            //   style: const TextStyle(
                            //       color: Colors.grey,
                            //       fontWeight: FontWeight.normal),
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onChatClick,
                        icon: SvgPicture.asset(
                          'assets/chat_icons/chat.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
