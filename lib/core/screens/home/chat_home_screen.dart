import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/screens/loading_screen.dart';

import '../../../features/chat/presentation/chat_provider.dart';
import '../../../utils/functions.dart';
import '../chat_error_screen.dart';
import '../search_page/search_page_screen.dart';
import '../widgets/appbar.dart';
import '../widgets/start_chat_message.dart';
import 'home_widgets/room_list_view.dart';

class ChatHomeScreen extends StatelessWidget {
  final bool isSwitchedAccount;
  final String? accessToken, refreshToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const ChatHomeScreen(
      {Key? key,
      this.isSwitchedAccount = false,
      this.accessToken,
      this.refreshToken,
      this.onViewOrderDetailsClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => isSwitchedAccount
          ? ChatProvider.brandSignIn(
              isSwitchedAccount, accessToken!, refreshToken!)
          : ChatProvider.userSignIn(
              isSwitchedAccount, accessToken!, refreshToken!),
      child: _ChatHomeScreen(
          isSwitchedAccount, accessToken, onViewOrderDetailsClick),
    );
  }
}

class _ChatHomeScreen extends StatefulWidget {
  final bool? isSwitchedAccount;
  final String? accessToken;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const _ChatHomeScreen(
      this.isSwitchedAccount, this.accessToken, this.onViewOrderDetailsClick);

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

  late ChatProvider chatProvider;

  int brandListCount = 0, userListCount = 0;

  late Stream<List<types.Room>> stream;

  String stateChangeMessage = '';

  @override
  void initState() {
    chatProvider = context.read<ChatProvider>();
    initializeFlutterFire();
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      chatProvider.clearRoomList();
    } else {
      chatProvider.getLocalRoomList();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();
    if (_error) {
      return Container();
    }

    if (!_initialized || chatProvider.apiStatus == ApiStatus.called) {
      return const Scaffold(body: LoadingScreen());
    }

    if (chatProvider.apiStatus == ApiStatus.failed) {
      return const ChatErrorScreen();
    }

    return Scaffold(
        appBar: chatAppBar(context,
            goToSearch: () => pushTo(
                SearchPage(
                    accessToken: widget.accessToken,
                    onViewOrderDetailsClick: widget.onViewOrderDetailsClick!),
                context)),
        body: chatProvider.isRoomListEmpty
            ? StartChatMessage(
                goToSearch: () => pushTo(
                    SearchPage(
                        accessToken: widget.accessToken,
                        onViewOrderDetailsClick:
                            widget.onViewOrderDetailsClick!),
                    context),
              )
            : RoomListView(
                onTap: onTabTapped,
                onViewOrderDetailsClick: widget.onViewOrderDetailsClick,
                isSwitchedAccount: widget.isSwitchedAccount ?? false,
                selectedTabIndex: selectedTabIndex,
                chatProvider: chatProvider,
                stream: stream));
  }

  onTabTapped(int index) {
    setState(() => selectedTabIndex = index);
    chatProvider.updateTabIndex(index);
  }

  void initializeFlutterFire() async {
    try {
      await Firebase.initializeApp();
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (mounted) {
          if (FirebaseAuth.instance.currentUser != null) {
            stream = FirebaseChatCore.instance.rooms();
          }
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
}
