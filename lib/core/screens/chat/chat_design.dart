import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/screens/chat/all_chat_screen.dart';
import 'package:ttp_chat/core/screens/chat/chats_screen.dart';
import 'package:ttp_chat/core/screens/chat/friends_chat_screen.dart';
import 'package:ttp_chat/features/chat/domain/chat_sign_in_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';

import 'merchants_chat_screen.dart';

class ChatDesigns extends StatelessWidget {

  bool isSwitchedAccount;
  Map<String, dynamic>? authData;
  BrandChatFirebaseTokenResponse? brandFirebaseTokenResponse;

  ChatDesigns({this.isSwitchedAccount = false, this.authData, this.brandFirebaseTokenResponse});

  @override
  Widget build(BuildContext context) {
    return
      ChangeNotifierProvider<ChatProvider>(
      create: (context) => isSwitchedAccount
          ? ChatProvider.brandSignIn(isSwitchedAccount, brandFirebaseTokenResponse!)
          : ChatProvider.userSignIn(isSwitchedAccount, authData!),
      child: _ChatDesigns(isSwitchedAccount, brandFirebaseTokenResponse != null ? brandFirebaseTokenResponse!.brandName : null),
    );
  }
}


class _ChatDesigns extends StatefulWidget{

  final bool? isSwitchedAccount;
  final String? brandName;

  _ChatDesigns(this.isSwitchedAccount, [this.brandName]);

  @override
  _ChatDesignsState createState() => _ChatDesignsState();
}

class _ChatDesignsState extends State<_ChatDesigns> with TickerProviderStateMixin{

  late ChatProvider chatProvider;

  @override
  void initState() {
    super.initState();

    chatProvider = context.read<ChatProvider>();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(widget.isSwitchedAccount!)
    {
      signOutBrandFromFB();
    }
    else {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();

    if(!widget.isSwitchedAccount!) {
      if(chatProvider.apiStatus == ApiStatus.called) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    return WillPopScope(
      onWillPop: () async{
        if(widget.isSwitchedAccount!)
          {
            signOutBrandFromFB();
            return true;
          }
        else {
          FirebaseAuth.instance.signOut();
          return true;
        }
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                'assets/icons/chat.svg',
                color: Theme.of(context).primaryColor,
                width: 18,
                height: 18,
              ),
            ),
            centerTitle: false,
            titleSpacing: 1,
            title: Text(
              widget.brandName != null ? 'All Activity - ${widget.brandName}' : 'All Activity',
              style: appBarTitleStyle(context),
            ),
            actions: [
              IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/chat_search.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: (){}),
              IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/chat_edit.svg',
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: (){})
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: ChatTypeToggle(),
            ),
          ),
          body: getBody()),
    );
  }

  getBody()
  {
    switch(context.read<ChatProvider>().selectedTab!.title)
    {
      case 'All':
        return AllChatScreen(widget.isSwitchedAccount!);
        break;
      case 'Chats':
        return ChatsScreen(widget.isSwitchedAccount!);
        break;
      case 'Friends':
        return FriendsChatScreen(widget.isSwitchedAccount!);
        // return ChatsScreen();
        break;
      case 'Merchants':
        return MerchantsChatScreen(widget.isSwitchedAccount!);
        // return ChatsScreen();
        break;
      default:
        const SizedBox();
    }
  }

  signOutBrandFromFB() async{
    FirebaseApp secondaryApp = Firebase.app('secondary');
    FirebaseAuth.instanceFor(app: secondaryApp).signOut();
  }
}

class ChatTypeToggle extends StatefulWidget {

  @override
  _ChatTypeToggleState createState() => _ChatTypeToggleState();
}

class _ChatTypeToggleState extends State<ChatTypeToggle> {
  @override
  Widget build(BuildContext context) {
    context.watch<ChatProvider>();
    return Container(
      height: 45,
      padding: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: context.read<ChatProvider>().tabs.map((e) {
          int index = context.read<ChatProvider>().tabs.indexOf(e);
          return _ChatTab(
            title: e.title!,
            isSelected: e.isSelected!,
            onTap: () {
              context.read<ChatProvider>().toggleTabSelection(index);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  final String? title;
  final bool? isSelected;
  final VoidCallback? onTap;

  const _ChatTab({
    Key? key,
    @required this.title,
    @required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: isSelected! ? Theme.of(context).primaryColor : Colors.grey[300]!),
            color: isSelected!
                ? Theme.of(context).primaryColor
                : null,
          ),
          child: Text(
            title!,
            style: Theme.of(context).textTheme.headline4!.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isSelected!
                  ? Colors.white
                  : Theme.of(context).primaryColor,
            ),
          )),
    );
  }
}

