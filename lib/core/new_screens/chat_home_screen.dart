import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';
import 'package:ttp_chat/core/new_screens/chat_error_screen.dart';
import 'package:ttp_chat/core/new_screens/rooms_list.dart';
import 'package:ttp_chat/core/new_screens/search_user/search_user_screen.dart';
import 'package:ttp_chat/core/new_screens/search_user/widgets/search_tab_bar.dart';
import 'package:ttp_chat/core/new_screens/widgets/appbar.dart';
import 'package:ttp_chat/core/new_screens/widgets/helpers.dart';
import 'package:ttp_chat/core/new_screens/widgets/start_chat_message.dart';
import 'package:ttp_chat/core/screens/loading_screen.dart';
import 'package:ttp_chat/core/widgets/input_search.dart';
import 'package:ttp_chat/core/widgets/rive_anim.dart';
import 'package:ttp_chat/core/widgets/rive_anim_controller.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/utils/functions.dart';

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

  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<bool>? _trigger;

  @override
  void initState() {

    rootBundle.load('assets/loader_anim.riv').then(
          (data) async {
        // Load the RiveFile from the binary data.
        final file = RiveFile.import(data);

        // The artboard is the root of the animation and gets drawn in the
        // Rive widget.
        final artboard = file.mainArtboard;
        var controller = StateMachineController.fromArtboard(
          artboard,
          'State Machine 1',
          onStateChange: _onStateChange,
        );
        if (controller != null) {
          artboard.addController(controller);
          _trigger = controller.findInput('Trigger 1');
        }
        setState(() => _riveArtboard = artboard);
      },
    );

    chatProvider = context.read<ChatProvider>();
    initializeFlutterFire();

    super.initState();
  }

  void _onStateChange(String stateMachineName, String stateName) => setState(
        () => stateChangeMessage =
    'State Changed in $stateMachineName to $stateName',
  );

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

    if (!_initialized) {
      return Container();
    }

    if (chatProvider.apiStatus == ApiStatus.called) {
      return const Scaffold(body: LoadingScreen());
    }

    if (chatProvider.apiStatus == ApiStatus.failed) {
      return const ChatErrorScreen();
    }

    return Scaffold(
        appBar: chatAppBar(context,
            goToSearch: () => pushTo(
                SearchUserScreen(
                    accessToken: widget.accessToken,
                    onViewOrderDetailsClick: widget.onViewOrderDetailsClick!),
                context)),
        body: chatProvider.isLoading
            ? const Center(child: LoadingScreen())
            : chatProvider.isRoomListEmpty
                ? StartChatMessage(
                    goToSearch: () => pushTo(
                        SearchUserScreen(
                            accessToken: widget.accessToken,
                            onViewOrderDetailsClick:
                                widget.onViewOrderDetailsClick!),
                        context),
                  )
                : roomsListWidget());
  }

  Widget roomsListWidget() {
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
        widget.isSwitchedAccount!
            ? Expanded(
                child: RoomsList(widget.isSwitchedAccount, widget.accessToken!,
                    widget.onViewOrderDetailsClick,
                    list: chatProvider.selectedTabIndex == 0
                        ? view.users
                        : view.brands),
              )
            : Expanded(
                child: RoomsList(widget.isSwitchedAccount, widget.accessToken!,
                    widget.onViewOrderDetailsClick,
                    list: chatProvider.selectedTabIndex == 0
                        ? view.brands
                        : view.users),
              )
      ],
    );
  }

  Widget _tabs() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: widget.isSwitchedAccount!
              ? [
                  _tab(0, 'People', chatProvider.userListCount),
                  _tab(1, 'Brands', chatProvider.brandListCount),
                ]
              : [
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
    return SearchTabBar(
      index: index,
      count: count,
      title: title,
      selectedTabIndex: selectedTabIndex,
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
        chatProvider.updateTabIndex(index);
      },
    );
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
