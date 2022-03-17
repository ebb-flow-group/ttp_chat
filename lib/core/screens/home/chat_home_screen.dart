import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/services/cache_service.dart';
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
        onViewOrderDetailsClick,
        onContactSupport,
      ),
    );
  }
}

class _ChatHomeScreen extends StatefulWidget {
  final Function(int?, String?, String?)? onViewOrderDetailsClick;
  final void Function()? onContactSupport;
  final String? accessToken;
  const _ChatHomeScreen(
    this.accessToken,
    this.onViewOrderDetailsClick,
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
        body: StreamBuilder<List<types.Room>>(
            stream: chatProvider.roomsStream,
            initialData: chatProvider.roomList.isEmpty ? null : chatProvider.roomList,
            builder: (context, snapshot) {
              if (FirebaseAuth.instance.currentUser != null && snapshot.connectionState != ConnectionState.waiting) {
                // log('****** Saving Room List to Cache ******');
                CacheService().saveRoomList(snapshot.data ?? [], chatProvider);
              }
              if (snapshot.hasData && snapshot.data?.isNotEmpty == true) {
                return RoomListView(
                    onTap: onTabTapped,
                    onViewOrderDetailsClick: widget.onViewOrderDetailsClick,
                    isSwitchedAccount: GetIt.I<ChatUtils>().isCreatorsApp,
                    selectedTabIndex: selectedTabIndex,
                    chatProvider: chatProvider,
                    stream: snapshot);
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              return StartChatMessage(
                goToSearch: () => pushTo(
                    SearchPage(
                        accessToken: widget.accessToken, onViewOrderDetailsClick: widget.onViewOrderDetailsClick!),
                    context),
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
          if (FirebaseAuth.instance.currentUser != null) {}
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
