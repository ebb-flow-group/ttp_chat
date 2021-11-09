import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ttp_chat/features/chat/domain/chat_users_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';

class ChatsScreen extends StatefulWidget {

  final bool? isSwitchedAccount;

  ChatsScreen(this.isSwitchedAccount);

  @override
  _ChatScreensState createState() => _ChatScreensState();
}

class _ChatScreensState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.only(top: 17),
      width: MediaQuery.of(context).size.width,
      child: StickyGroupedListView<ChatUsersModel, String>(
        elements: context.read<ChatProvider>().chatUsersList,
        groupBy: (ChatUsersModel element) => element.lastMessageTimeStamp.toString(),
        groupSeparatorBuilder: (ChatUsersModel element){

          DateTime headerDateTime = DateTime.fromMillisecondsSinceEpoch(element.lastMessageTimeStamp! * 1000);

          if(headerDateTime.day == DateTime.now().day)
            {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.5,
                        color: Colors.grey[300],
                        endIndent: 10,
                      ),
                    ),
                    const Text(
                      'Today',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1.5,
                        color: Colors.grey[300],
                        indent: 10,
                      ),
                    ),
                  ],
                ),
              );
            }
          else if(headerDateTime.day == DateTime.now().day - 1)
            {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.5,
                        color: Colors.grey[300],
                        endIndent: 10,
                      ),
                    ),
                    const Text(
                      'Yesterday',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1.5,
                        color: Colors.grey[300],
                        indent: 10,
                      ),
                    ),
                  ],
                ),
              );
            }
          else if(headerDateTime.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1)))
            {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1.5,
                        color: Colors.grey[300],
                        endIndent: 10,
                      ),
                    ),
                    const Text(
                      'Previous',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1.5,
                        color: Colors.grey[300],
                        indent: 10,
                      ),
                    ),
                  ],
                ),
              );
            }
          else
            {
              return Divider(
                thickness: 1.5,
                color: Colors.grey[300]);
            }
        },
        itemBuilder: (context, ChatUsersModel element) => ChatUsersWidget(0, element),
        itemScrollController: GroupedItemScrollController(), // optional
        itemComparator: (element1, element2) => element1.fullName!.compareTo(element2.fullName!),
        order: StickyGroupedListOrder.DESC, // optional
        separator: const SizedBox(height: 17),
        stickyHeaderBackgroundColor: Colors.transparent,
      )/*ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: context.read<ChatProvider>().chatUsersList.length,
        separatorBuilder: (context, __) {
          return SizedBox(
            height: 17,
          );
        },
        itemBuilder: (context, index){
          ChatUsersModel e = context.read<ChatProvider>().chatUsersList[index];
          return ChatUsersWidget(index, e);
        },
      )*/,
    );
  }
}

class ChatUsersWidget extends StatefulWidget {

  int index;
  ChatUsersModel chatUsersModel;

  ChatUsersWidget(this.index, this.chatUsersModel);

  @override
  _ChatUsersWidgetState createState() => _ChatUsersWidgetState();
}

class _ChatUsersWidgetState extends State<ChatUsersWidget> {

  bool isLogging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(widget.chatUsersModel),
        ));*/
      },
      child: Row(
        children: [

          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(
                        widget.chatUsersModel.avatar!
                    )
                )
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chatUsersModel.fullName!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.chatUsersModel.lastMessage!,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.normal
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(widget.chatUsersModel.lastMessageTimeStamp! * 1000)),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle
                      ),
                      child: Text(
                        widget.chatUsersModel.unreadMessagesCount.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12
                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          )

        ],
      ),
    );
  }
}
