import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../features/chat/domain/search_user_model.dart';
import '../../../../utils/functions.dart';

class SearchBrandTile extends StatelessWidget {
  const SearchBrandTile({Key? key, required this.brand, this.onChatClick}) : super(key: key);

  final Brands brand;
  final void Function()? onChatClick;

  @override
  Widget build(BuildContext context) {
    return isLoggedInUser(brand.username)
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.5),
            child: Row(
              children: [
                Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Icon(Icons.fastfood, color: Theme.of(context).primaryColor.withOpacity(0.2))),
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
          );
  }
}
