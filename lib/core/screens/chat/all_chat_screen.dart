import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/core/screens/chat/user_accounts.dart';
import 'package:ttp_chat/features/chat/domain/chat_sign_in_model.dart';
import 'package:ttp_chat/features/chat/domain/users_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/models/base_model.dart';
import 'package:ttp_chat/network/api_service.dart';
import 'package:ttp_chat/utils/show_message.dart';

class AllChatScreen extends StatefulWidget {

  final bool? isSwitchedAccount;

  AllChatScreen(this.isSwitchedAccount);

  @override
  _AllChatScreenState createState() => _AllChatScreenState();
}

class _AllChatScreenState extends State<AllChatScreen> {

  late ChatProvider chatProvider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    chatProvider = context.read<ChatProvider>();
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 17),
        width: MediaQuery.of(context).size.width,
        child: startChatMessage(),
      ),
    );
  }

  Widget startChatMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 50),
        SvgPicture.asset(
          'assets/icons/group_chat.svg',
          width: 50,
          height: 50,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(height: 10),
        Text(
          'Find all your interactions\nin one place.',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 10),
        const Text(
          'Chat with friends and sellers. Keep track of purchases and gifts. Get status updates on your orders. All in one place.',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
        ),
        chatProvider.chatSignInModel!.brandFirebaseTokenList!.isEmpty
            ? const SizedBox()
            : const SizedBox(height: 8),
        chatProvider.chatSignInModel!.brandFirebaseTokenList!.isEmpty
        ? const SizedBox()
        : GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserAccounts(
                        chatProvider.chatSignInModel!.brandFirebaseTokenList!)));
          },
          child: Text(
            'Brand managing >',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
        ),
        const SizedBox(height: 40),
        Row(
          children: [
            Expanded(
              child: Divider(
                thickness: 1.5,
                color: Colors.grey[300],
                endIndent: 10,
              ),
            ),
            const Text(
              'Start a chat with your friends',
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
        const SizedBox(height: 10),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: context.read<ChatProvider>().usersList.length,
              separatorBuilder: (context, __) {
                return const SizedBox(
                  height: 17,
                );
              },
              itemBuilder: (context, index) {
                UsersModel e = context.read<ChatProvider>().usersList[index];
                return UserWidget(index, e);
              },
            ),
          ),
        )
      ],
    );
  }

  void signInMVP() async {
    BaseModel<ChatSignInModel> response =
        await GetIt.I<ApiService>().signInMVP('shubham_8607', '8668292003');

    if (response.data != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserAccounts(response.data!.brandFirebaseTokenList!)));
    } else {
      showMessage(
        context,
        "Error",
        response.getException.getErrorMessage(),
      );
    }
  }
}

class UserWidget extends StatelessWidget {
  int index;
  UsersModel usersModel;

  UserWidget(this.index, this.usersModel);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(usersModel.avatar!))),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    usersModel.fullName!,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Text(
                    '@${usersModel.userName}',
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
                ],
              )
            ],
          ),
        ),
        ChatButton(
          isFollowed: usersModel.isFollowed!,
          onTap: () {
            if (!usersModel.isFollowed!) {
              context.read<ChatProvider>().followFriend(index);
            } else {}
          },
        )
      ],
    );
  }
}

class ChatButton extends StatelessWidget {
  final bool? isFollowed;
  final VoidCallback? onTap;

  const ChatButton({
    Key? key,
    @required this.isFollowed,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
          height: 32,
          width: 85,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: isFollowed!
                ? Theme.of(context).primaryColor
                : Theme.of(context).accentColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFollowed! ? Icons.message : Icons.person_add_alt_1_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                isFollowed! ? 'Chat' : 'Follow',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
              ),
            ],
          )),
    );
  }
}
