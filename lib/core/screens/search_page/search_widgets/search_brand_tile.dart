import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/chat/domain/search_user_model.dart';
import '../../../../utils/functions.dart';
import '../../../services/routes.dart';
import '../../chat_utils.dart';
import 'search_tile_avatar.dart';

class SearchBrandTile extends StatelessWidget {
  const SearchBrandTile({Key? key, required this.brand, this.onChatClick}) : super(key: key);

  final Brands brand;
  final void Function()? onChatClick;

  @override
  Widget build(BuildContext context) {
    return isLoggedInUser(brand.username)
        ? const SizedBox.shrink()
        : GestureDetector(
            onTap: () {
              if (!GetIt.I<ChatUtils>().isCreatorsApp && (brand.username?.isNotEmpty == true)) {
                context.push(Routes.homeOutletDetailPage, extra: brand.username);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.5),
              child: Row(
                children: [
                  SearchTileAvatar(brand.logo, radius: 30, name: brand.name),
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
                                brand.name ?? "",
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              // const SizedBox(height: 4),
                              // Text(
                              //   '@${brand.username}',
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
            ),
          );
  }
}
