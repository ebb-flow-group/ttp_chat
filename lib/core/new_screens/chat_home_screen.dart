import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/new_screens/brand_rooms_screen.dart';
import 'package:ttp_chat/core/new_screens/chat_error_screen.dart';
import 'package:ttp_chat/core/new_screens/search_user_screen.dart';
import 'package:ttp_chat/core/new_screens/user_rooms_screen.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/screens/chat/util.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/core/widgets/triangle_painter.dart';
import 'package:ttp_chat/features/chat/domain/chat_sign_in_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


class ChatHomeScreen extends StatelessWidget {

  final bool isSwitchedAccount;
  final String? accessToken, refreshToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const ChatHomeScreen({Key? key, this.isSwitchedAccount = false, this.accessToken, this.refreshToken, this.onViewOrderDetailsClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider<ChatProvider>(
        create: (context) => isSwitchedAccount
            ? ChatProvider.brandSignIn(isSwitchedAccount, accessToken!, refreshToken!)
            : ChatProvider.userSignIn(isSwitchedAccount, accessToken!, refreshToken!),
        child: _ChatHomeScreen(isSwitchedAccount, accessToken, onViewOrderDetailsClick),
      );
  }
}

class _ChatHomeScreen extends StatefulWidget {
  final bool? isSwitchedAccount;
  final String? accessToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const _ChatHomeScreen(this.isSwitchedAccount, this.accessToken, this.onViewOrderDetailsClick);

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<_ChatHomeScreen> {
  bool isSelected = true;
  int selectedTabIndex = 0;
  bool _error = false;
  bool _initialized = false;
  bool isRoomListEmpty = false;
  bool isLoading = false;
  User? _user;

  late ChatProvider chatProvider;

  int brandListCount = 0, userListCount = 0;

  @override
  void initState() {
    chatProvider = context.read<ChatProvider>();
    initializeFlutterFire();
    super.initState();
  }

  /*@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    FirebaseAuth.instance.signOut();
  }*/

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
    }

    if(chatProvider.apiStatus == ApiStatus.called) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if(chatProvider.apiStatus == ApiStatus.failed){
      return const ChatErrorScreen();
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDFBEF).withOpacity(0.2),
          title: Text('Chat',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontSize: 24)),
          actions: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchUserScreen(accessToken: widget.accessToken, onViewOrderDetailsClick: widget.onViewOrderDetailsClick!)));
                  },
                  icon: SvgPicture.asset(
                    'assets/chat_icons/start_new_chat.svg',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ],
          centerTitle: false,
        ),
        body: widget.isSwitchedAccount!
            ? StreamBuilder<List<types.Room>>(
          stream: /*widget.isSwitchedAccount! ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).rooms() : */FirebaseChatCore.instance.rooms(),
          initialData: const [],
          builder: (context, snapshot) {
            switch (snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return startChatMessageWidget();
                }

                if (snapshot.hasError) {
                  print('BRAND STREAM B ERROR: ${snapshot.error}');
                }
                return brandRoomsListWidget(snapshot);
            }

          },
        )
            : chatProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : chatProvider.isRoomListEmpty
                ? startChatMessageWidget()
                : roomsListWidget());
  }

  Widget startChatMessageWidget() {
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
              onPressed: () {
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchUserScreen()));*/
              })
        ],
      ),
    );
  }

  Widget roomsListWidget(){
    return Column(
      children: [
        const SizedBox(height: 17),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 17.0),
          child: InputSearch(
              hintText: 'Search a brand, user or mobile',
              onChanged: (String value) {}),
        ),
        const SizedBox(height: 17),
        _tabs(),
        chatProvider.selectedTabIndex == 0
        ? BrandRoomsScreen(widget.isSwitchedAccount, widget.onViewOrderDetailsClick)
        : UserRoomsScreen(widget.isSwitchedAccount, widget.onViewOrderDetailsClick),
      ],
    );
  }

  Widget brandRoomsListWidget(AsyncSnapshot<List<types.Room>> snapshot){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 17),
      padding: const EdgeInsets.only(top: 17),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          var brandList = snapshot.data!;

          return GestureDetector(
            onTap: () async{
              var result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChatPage(brandList[index], widget.isSwitchedAccount!, widget.onViewOrderDetailsClick!),
                ),
              );

              if(result != null){
                setState(() {});
              }
            },
            child: Row(
              children: [
                _buildAvatar(brandList[index]),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              brandList[index].name!,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            getLastMessageWidget(brandList[index].metadata!['last_messages']),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            getLastMessageDateTime(brandList[index].metadata!['last_messages']['createdAt'] as Timestamp),
                            style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  height: 1
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
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 17);
        },
      ),
    );
  }

  Widget _buildAvatar(types.Room room) {
    var color = Colors.white;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
              (u) => u.id != FirebaseAuth.instance.currentUser!.uid,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found
      }
    }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

  Widget _tabs() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tab(0, 'Brands', chatProvider.brandListCount),
            _tab(1, 'People', chatProvider.userListCount),
          ],
        ),
        Container(
          height: 3,
          color: Theme.of(context).primaryColor,
        )
      ],
    );
  }

  Widget _tab(int index, String title, int count) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        chatProvider.updateTabIndex(index);
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: chatProvider.selectedTabIndex == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey[400]),
                ),
                const SizedBox(width: 6),
                count == 0
                    ? const SizedBox()
                    : Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, height: 1),
                  ),
                )
              ],
            ),
            const SizedBox(height: 2),
            chatProvider.selectedTabIndex == index
                ? CustomPaint(
                    painter: TrianglePainter(
                      strokeColor: Theme.of(context).primaryColor,
                      paintingStyle: PaintingStyle.fill,
                    ),
                    child: const SizedBox(
                      height: 6,
                      width: 12,
                    ),
                  )
                : const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget noRoomWidget(){
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

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if(mounted)
        {
          setState(() {
            _user = user;
          });
        }
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = true;
      });
    }
  }

  Widget getLastMessageWidget(Map<String, dynamic> data){
    String lastMessage = '';

    if(data['type'] == 'image'){
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
    }
    else if(data['type'] == 'file'){
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
    }
    else if(data['type'] == 'voice'){
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
    }
    else if(data['type'] == 'custom'){
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
    }
    else if(data['type'] == 'text'){
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

    return const SizedBox();
  }

  String getLastMessageDateTime(Timestamp timeStamp){
    DateTime d = timeStamp.toDate();
    return DateFormat('hh:mm a').format(d);
  }
}
