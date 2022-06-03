import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:route_parser/route_parser.dart';

import '../../../../features/chat/domain/search_user_model.dart';
import '../../../../utils/functions.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import 'search_tile_avatar.dart';

class SearchUserTile extends StatelessWidget {
  const SearchUserTile(this.user, {Key? key, this.onChatClick}) : super(key: key);
  final Users user;
  final void Function()? onChatClick;

  @override
  Widget build(BuildContext context) {
    return isLoggedInUser(user.uid)
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              if (!GetIt.I<ChatUtils>().isCreatorsApp && (user.uid != null) && user.type == UserType.brand) {
                context.push(RouteParser(Routes.homeOutletPage).reverse({'id': user.uid!}));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.5),
              child: Row(
                children: [
                  SearchTileAvatar(user.imgUrl, radius: 30, name: '${user.firstName ?? ""} ${user.lastName ?? ""}'),
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
                                user.firstName != null || user.lastName != null
                                    ? '${user.firstName ?? ""} ${user.lastName ?? ""}'
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
                            'assets/icon/chat.svg',
                            package: 'ttp_chat',
                            width: 20,
                            height: 20,
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
