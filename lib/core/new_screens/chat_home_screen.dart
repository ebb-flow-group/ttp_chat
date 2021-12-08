import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/screens/chat/chats_screen.dart';
import 'package:ttp_chat/core/screens/chat/util.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/core/widgets/triangle_painter.dart';
import 'package:ttp_chat/features/chat/domain/chat_sign_in_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;


class ChatHomeScreen extends StatelessWidget {

  final bool isSwitchedAccount;
  final Map<String, dynamic>? authData;
  final BrandChatFirebaseTokenResponse? brandFirebaseTokenResponse;

  const ChatHomeScreen({Key? key, this.isSwitchedAccount = false, this.authData, this.brandFirebaseTokenResponse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider<ChatProvider>(
        create: (context) => isSwitchedAccount
            ? ChatProvider.brandSignIn(isSwitchedAccount, brandFirebaseTokenResponse!)
            : ChatProvider.userSignIn(isSwitchedAccount, authData!),
        child: _ChatHomeScreen(isSwitchedAccount, brandFirebaseTokenResponse != null ? brandFirebaseTokenResponse!.brandName : null),
      );
  }
}

class _ChatHomeScreen extends StatefulWidget {
  final bool? isSwitchedAccount;
  final String? brandName;

  const _ChatHomeScreen(this.isSwitchedAccount, [this.brandName]);

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<_ChatHomeScreen> {
  bool isSelected = true;
  int selectedTabIndex = 0;
  bool _error = false;
  bool _initialized = false;
  User? _user;

  @override
  void initState() {
    initializeFlutterFire();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container();
    }

    if (!_initialized) {
      return Container();
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
                    /*Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatErrorScreen()));*/
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
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          child: StreamBuilder<List<types.Room>>(
            stream: widget.isSwitchedAccount! ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).rooms() : FirebaseChatCore.instance.rooms(),
            initialData: const [],
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(
                    bottom: 200,
                  ),
                  child: const Text('No rooms'),
                );
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final room = snapshot.data![index];

                  return GestureDetector(
                    onTap: () {

                      /*Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(room, widget.isSwitchedAccount!),
                        ),
                      );*/
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          _buildAvatar(room),
                          Text(room.name ?? '', style: const TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ));
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
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 17),
            padding: const EdgeInsets.only(top: 17),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount:
              context.read<ChatProvider>().chatUsersList.length,
              itemBuilder: (context, index) {
                return ChatUsersWidget(0,
                    context.read<ChatProvider>().chatUsersList[index]);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 17);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _tab(0, 'Brands', 3),
            _tab(1, 'People', 4),
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
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedTabIndex = index;
          });
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
                        color: selectedTabIndex == index
                            ? Theme.of(context).primaryColor
                            : Colors.grey[400]),
                  ),
                  const SizedBox(width: 6),
                  Container(
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
              selectedTabIndex == index
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

  Widget _buildAvatar(types.Room room) {
    var color = Colors.white;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
              (u) => u.id != _user!.uid,
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
}
