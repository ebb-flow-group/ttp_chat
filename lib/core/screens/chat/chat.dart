import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/features/chat/domain/chat_users_model.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';
import 'package:ttp_chat/theme/style.dart';

class ChatScreen extends StatelessWidget {
  ChatUsersModel usersModel;

  ChatScreen(this.usersModel);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) =>
          ChatProvider.initialiseUserAndLoadMessages(usersModel),
      child: _ChatScreen(),
    );
  }
}

class _ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<_ChatScreen> {
  var _user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');
  List<types.Message> _messages = [];
  late ChatProvider chatProvider;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    chatProvider = context.read<ChatProvider>();
    chatProvider.openTheRecorder();
    chatProvider.flutterSoundPlayer.openAudioSession();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    chatProvider.disposeAudioMessageTimer();
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: false,
        titleSpacing: 1,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(chatProvider.usersModel!.avatar!))),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              chatProvider.usersModel!.fullName!,
              style: appBarTitleStyle(context),
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: SvgPicture.asset(
                'assets/icon/settings.svg',
                color: Theme.of(context).primaryColor,
                height: 18,
                width: 18,
              ),
              onPressed: () {}),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Stack(
            children: [
              Chat(
                messages: chatProvider.messagesList,
                // messages: [],
                isAttachmentUploading: chatProvider.isAttachmentUploading,
                onAttachmentPressed: _handleAttachmentPressed,
                onVoiceMessagePressed: _handleVoiceMessagePressed,
                onMessageTap: chatProvider.handleMessageTap,
                onPreviewDataFetched: chatProvider.handlePreviewDataFetched,
                onSendPressed: chatProvider.handleSendPressed,
                user: chatProvider.user,
                showUserAvatars: true,
                theme: DefaultChatTheme(
                  messageBorderRadius: 0.0,
                  backgroundColor:
                      ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor,
                  primaryColor: Theme.of(context).accentColor,
                  secondaryColor: Theme.of(context).primaryColor,
                  inputTextColor: Theme.of(context).primaryColor,
                  sentMessageBodyTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                  sentMessageCaptionTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                  sentMessageLinkTitleTextStyle: const TextStyle(color: Colors.white),
                  sentMessageLinkDescriptionTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                  receivedMessageBodyTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                  receivedMessageCaptionTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                  receivedMessageLinkTitleTextStyle:
                      const TextStyle(color: Colors.white),
                  receivedMessageLinkDescriptionTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.normal),
                  sentMessageDocumentIconColor: Colors.white,
                  receivedMessageDocumentIconColor: Colors.white,
                ),
                emptyState: emptyMessageState(),
                customDateHeaderText: (DateTime dateTime) {
                  return DateFormat('dd MMM | hh:mm a')
                      .format(dateTime)
                      .toUpperCase();
                },
              ),
              if (chatProvider.voiceMessageFile != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      0, //24 + _query.padding.left,
                      20,
                      0, //24 + _query.padding.right,
                      20 +
                          MediaQuery.of(context).viewInsets.bottom +
                          MediaQuery.of(context).padding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeUtils
                          .defaultAppThemeData.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                          color: const Color(0xFF000000).withOpacity(.15),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /*IconButton(
                          icon: Icon(
                            chatProvider.isRecordedVoiceMessageFilePlaying
                                ? Icons.delete
                                : Icons.play_arrow_rounded,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            // chatProvider.removeRecordedVoiceMessage();
                            // chatProvider.stopVoiceMessageAnimation();

                            if (chatProvider.voiceMessageFile != null) {
                              if (chatProvider
                                  .isRecordedVoiceMessageFilePlaying) {
                                chatProvider.stopVoiceMessageAnimation();
                              } else {
                                chatProvider.playVoiceMessageAnimation();
                              }
                            }
                          },
                        ),*/
                        IconButton(
                          icon: SvgPicture.asset(
                            chatProvider.isRecordedVoiceMessageFilePlaying
                                ? 'assets/icon/delete.svg'
                                : 'assets/icon/play.svg',
                            color: Theme.of(context).primaryColor,
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {
                            // chatProvider.removeRecordedVoiceMessage();
                            // chatProvider.stopVoiceMessageAnimation();

                            if (chatProvider.voiceMessageFile != null) {
                              if (chatProvider
                                  .isRecordedVoiceMessageFilePlaying) {
                                chatProvider.stopVoiceMessageAnimation();
                              } else {
                                chatProvider.playVoiceMessageAnimation();
                              }
                            }
                          },
                        ),
                        Expanded(
                          child: Container(
                            height: 46,
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                color: ThemeUtils.defaultAppThemeData
                                    .scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[300]!,
                                      blurRadius: 10.0,
                                      spreadRadius: 5),
                                ]),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                chatProvider.isRecordedVoiceMessageFilePlaying
                                    ? MusicVisualizer()
                                    : SizedBox(
                                        height: 20,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: List.generate(16, (index) {
                                            return Container(
                                              width: 7,
                                              margin: const EdgeInsets.only(right: 2),
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .accentColor,
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              height: 5,
                                            );
                                          }),
                                        ),
                                      ),
                                if (chatProvider.voiceMessageFile != null)
                                  Text(
                                    '${chatProvider.recordedVoiceMessageFileDuration ?? 0}s',
                                    style: appBarTitleStyle(context).copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: SvgPicture.asset(
                            'assets/icon/send.svg',
                            color: Theme.of(context).accentColor,
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () {
                            chatProvider.addVoiceMessage();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  _handleVoiceMessagePressed() {
    FocusScope.of(context).requestFocus(FocusNode());
    chatProvider.handleVoiceMessageSelection(context);
  }

  void _handleAttachmentPressed() {
    FocusScope.of(context).requestFocus(FocusNode());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.grey.withOpacity(.75),
      elevation: 20,
      builder: (BuildContext context) {
        return Wrap(children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(20)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _ListItem(
                      leading: SvgPicture.asset(
                        'assets/icon/photo.svg',
                        height: 18,
                        width: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Upload a photo'),
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.handleImageSelection();
                      },
                    ),
                    _ListItem(
                      leading: SvgPicture.asset(
                        'assets/icon/file.svg',
                        height: 18,
                        width: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Upload a file'),
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.handleFileSelection();
                      },
                    ),
                    // Divider(),
                    const SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          ),
        ]);
      },
    );
  }

  Widget emptyMessageState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Text(
            'You\'re about to chat up...',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 30),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(chatProvider.usersModel!.avatar!))),
          ),
          const SizedBox(height: 14),
          Text(
            chatProvider.usersModel!.fullName!,
            style: appBarTitleStyle(context),
          ),
          const SizedBox(height: 4),
          Text(
            '@${chatProvider.usersModel!.userName}',
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).primaryColor,
              ),
              child: Text(
                "View Profile",
                style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              onPressed: () {}),
        ],
      ),
    );
  }
}

class AttachmentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ListItem(
                leading: Image.asset(
                  'assets/icon/dine_in_tab_icon.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Upload a photo'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().handleImageSelection();
                },
              ),
              _ListItem(
                leading: Image.asset(
                  'assets/icon/takeaway_tab_icon.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Upload a file'),
                onTap: () {
                  Navigator.pop(context);
                  context.read<ChatProvider>().handleFileSelection();
                },
              ),
              _ListItem(
                leading: Image.asset(
                  'assets/icon/delivery_tab_icon.png',
                  height: 20,
                  width: 20,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Upload a voice message'),
                showDivider: true,
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<ChatProvider>()
                      .handleVoiceMessageSelection(context);
                },
              ),
              // Divider(),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Widget? leading;
  final Text? title;
  final Function()? onTap;
  final bool? showDivider;

  const _ListItem({
    Key? key,
    this.leading,
    this.title,
    this.onTap,
    this.showDivider = true,
  }) : super(key: key);

  TextStyle _titleTextStyle(ThemeData theme) {
    return theme.textTheme.bodyText2!.copyWith(
      fontWeight: FontWeight.w600,
      color: onTap != null ? theme.primaryColor : theme.disabledColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    TextStyle titleTextStyle = _titleTextStyle(theme);
    final Widget titleText = AnimatedDefaultTextStyle(
      style: titleTextStyle,
      duration: kThemeChangeDuration,
      child: title ?? Container(),
    );
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 25,
                  width: 25,
                  child: leading,
                ),
                const SizedBox(width: 20),
                titleText,
              ],
            ),
          ),
          showDivider! ? const Divider(indent: 50, endIndent: 20) : Container(),
        ],
      ),
    );
  }
}

class VisualComponent extends StatefulWidget {
  final int? duration;
  final Color? color;

  VisualComponent({this.duration, this.color});

  @override
  _VisualComponentState createState() => _VisualComponentState();
}

class _VisualComponentState extends State<VisualComponent>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationController = AnimationController(
        duration: Duration(milliseconds: widget.duration!), vsync: this);
    final curvedAnimation = CurvedAnimation(
        parent: animationController, curve: Curves.easeInOutCubic);

    animation = Tween<double>(begin: 5, end: 100).animate(curvedAnimation)
      ..addListener(() {
        setState(() {});
      });
    animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5)),
      height: animation.value,
    );
  }
}

class MusicVisualizer extends StatelessWidget {
  List<Color> colors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.redAccent,
    Colors.yellowAccent
  ];
  List<int> duration = [900, 700, 600, 800, 500];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(
            16,
            (index) => VisualComponent(
                  duration: duration[index % 5],
                  color: colors[index % 4],
                )),
      ),
    );
  }
}
