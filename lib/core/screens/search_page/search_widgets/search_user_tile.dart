import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/core/widgets/empty.dart';

import '../../../../config.dart';
import '../../../../features/chat/domain/search_user_model.dart';
import '../../../../utils/functions.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import 'search_tile_avatar.dart';

class SearchUserTile extends StatelessWidget {
  const SearchUserTile(this.user, {Key? key, this.onChatClick}) : super(key: key);
  final SearchUser user;
  final void Function()? onChatClick;

  @override
  Widget build(BuildContext context) {
    if (isLoggedInUser(user.uid)) return const Empty();
    return GestureDetector(
      onTap: () {
        if (!GetIt.I<ChatUtils>().isCreatorsApp && (user.uid != null)) {
          if (user.type == UserType.brand) {
            context.push(Routes.homeOutletDetailPage, extra: user.uid);
          } else {
            context.push(RouteParser(Routes.userProfilePage).reverse({'id': Uri.encodeComponent(user.uid!)}));
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.5),
        child: Row(
          children: [
            SearchTileAvatar(user.imgUrl, radius: 25, name: user.fullName),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          user.fullName,
                          style: Ts.bold13(Config.primaryColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onChatClick,
                    icon: SvgPicture.asset(
                      'assets/icon/chat.svg',
                      package: 'ttp_chat',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
