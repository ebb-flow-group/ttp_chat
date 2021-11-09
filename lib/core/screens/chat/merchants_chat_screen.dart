import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:ttp_chat/core/screens/chat/chat_page.dart';
import 'package:ttp_chat/core/screens/chat/util.dart';

class MerchantsChatScreen extends StatefulWidget {

  final bool? isSwitchedAccount;

  MerchantsChatScreen(this.isSwitchedAccount);

  @override
  _MerchantsChatScreenState createState() => _MerchantsChatScreenState();
}

class _MerchantsChatScreenState extends State<MerchantsChatScreen> {
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

    return Container(
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

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(room, widget.isSwitchedAccount!),
                    ),
                  );
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
