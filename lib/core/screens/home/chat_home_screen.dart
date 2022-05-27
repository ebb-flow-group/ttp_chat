import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../features/chat/presentation/chat_provider.dart';
import '../../../utils/functions.dart';
import '../chat_error_screen.dart';
import '../chat_utils.dart';
import '../loading_screen.dart';
import '../search_page/search_page_screen.dart';
import '../widgets/appbar.dart';
import '../widgets/start_chat_message.dart';
import 'home_widgets/room_list_view.dart';

class ChatHomeScreen extends StatelessWidget {
  final String? accessToken, refreshToken;
  final void Function()? onContactSupport;
  final void Function()? onViewOrdersPage;
  @Deprecated('Using Go Router for navigation Now, this can be removed')
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const ChatHomeScreen({
    Key? key,
    this.onContactSupport,
    this.onViewOrdersPage,
    this.onViewOrderDetailsClick,
    this.accessToken,
    this.refreshToken,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => GetIt.I<ChatUtils>().isCreatorsApp
          ? ChatProvider.brandSignIn(accessToken!, refreshToken!)
          : ChatProvider.userSignIn(accessToken!, refreshToken!),
      child: _ChatHomeScreen(
        accessToken,
        onContactSupport,
      ),
    );
  }
}

class _ChatHomeScreen extends StatefulWidget {
  final void Function()? onContactSupport;
  final String? accessToken;
  const _ChatHomeScreen(
    this.accessToken,
    this.onContactSupport,
  );

  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<_ChatHomeScreen> {
  bool isSelected = true;
  int selectedTabIndex = 0;
  bool _error = false;
  bool _initialized = false;
  bool isLoading = false;

  late ChatProvider chatProvider;

  @override
  void initState() {
    chatProvider = context.read<ChatProvider>();
    initializeFlutterFire();
    super.initState();
    //Not using cache Service now
    // if (FirebaseAuth.instance.currentUser == null) {
    //   CacheService().clearRoomList();
    // } else {
    //   chatProvider.getLocalRoomList();
    // }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();
    if (_error) {
      return ChatErrorScreen(onContactSupport: widget.onContactSupport);
    }

    if (chatProvider.apiStatus == ApiStatus.failed) {
      return ChatErrorScreen(onContactSupport: widget.onContactSupport);
    }

    if (!_initialized || chatProvider.apiStatus == ApiStatus.called) {
      return const Scaffold(body: LoadingScreen());
    }
    return Scaffold(
        appBar: chatAppBar(context, goToSearch: () => pushTo(SearchPage(accessToken: widget.accessToken), context)),
        body: StreamBuilder<List<types.Room>>(
            stream: chatProvider.roomsStream,
            initialData: GetIt.I<ChatUtils>().roomList.isEmpty ? null : GetIt.I<ChatUtils>().roomList,
            builder: (context, snapshot) {
              if (FirebaseAuth.instance.currentUser != null && snapshot.connectionState != ConnectionState.waiting) {
                // log('****** Saving Room List to Cache ******');
                GetIt.I<ChatUtils>().updateRoomList(snapshot.data ?? []);
                //  CacheService().saveRoomList(snapshot.data ?? [], chatProvider);
              }
              if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                return RoomListView(
                    onTap: onTabTapped,
                    isSwitchedAccount: GetIt.I<ChatUtils>().isCreatorsApp,
                    selectedTabIndex: selectedTabIndex,
                    chatProvider: chatProvider,
                    stream: snapshot);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              return StartChatMessage(
                goToSearch: () => pushTo(SearchPage(accessToken: widget.accessToken), context),
              );
            }));
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
            setState(() => _initialized = true);
          }
        }
      }).onError((error) {
        setState(() => _error = true);
      });
    } catch (e) {
      setState(() => _error = true);
    }
  }
}
