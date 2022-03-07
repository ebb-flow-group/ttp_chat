import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/services/cache_service.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../features/chat/presentation/chat_provider.dart';
import '../../../packages/chat_core/src/firebase_chat_core.dart';
import '../../../utils/functions.dart';
import '../chat_error_screen.dart';
import '../loading_screen.dart';
import '../search_page/search_page_screen.dart';
import '../widgets/appbar.dart';
import '../widgets/start_chat_message.dart';
import 'home_widgets/room_list_view.dart';

class ChatHomeScreen extends StatelessWidget {
  final bool isSwitchedAccount;
  final String? accessToken, refreshToken;
  final void Function()? onContactSupport;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const ChatHomeScreen({
    Key? key,
    this.onContactSupport,
    this.onViewOrderDetailsClick,
    this.isSwitchedAccount = false,
    this.accessToken,
    this.refreshToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => isSwitchedAccount
          ? ChatProvider.brandSignIn(accessToken!, refreshToken!)
          : ChatProvider.userSignIn(accessToken!, refreshToken!),
      child: _ChatHomeScreen(isSwitchedAccount, accessToken, onViewOrderDetailsClick, onContactSupport),
    );
  }
}

class _ChatHomeScreen extends StatefulWidget {
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  final bool? isSwitchedAccount;
  final void Function()? onContactSupport;
  final String? accessToken;
  const _ChatHomeScreen(this.isSwitchedAccount, this.accessToken, this.onViewOrderDetailsClick, this.onContactSupport);

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

  @override
  void initState() {
    chatProvider = context.read<ChatProvider>();
    initializeFlutterFire();
    super.initState();
    if (FirebaseAuth.instance.currentUser == null) {
      CacheService().clearRoomList();
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
    if (!_initialized || chatProvider.apiStatus == ApiStatus.called) {
      return const Scaffold(body: LoadingScreen());
    }
    if (_error) {
      return Container();
    }

    if (chatProvider.apiStatus == ApiStatus.failed) {
      return ChatErrorScreen(onContactSupport: widget.onContactSupport);
    }

    return Scaffold(
        appBar: chatAppBar(context,
            goToSearch: () => pushTo(
                SearchPage(accessToken: widget.accessToken, onViewOrderDetailsClick: widget.onViewOrderDetailsClick!),
                context)),
        body: chatProvider.isRoomListEmpty
            ? StartChatMessage(
                goToSearch: () => pushTo(
                    SearchPage(
                        accessToken: widget.accessToken, onViewOrderDetailsClick: widget.onViewOrderDetailsClick!),
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
            stream = FirebaseChatCore.instance.rooms(orderByUpdatedAt: true);
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
