import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/recording_animation.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/core/screens/loading_screen.dart';
import 'package:ttp_chat/core/services/deeplink_builder.dart';
import 'package:ttp_chat/core/services/l.dart';
import 'package:ttp_chat/utils/message_utils.dart';
import 'package:ttp_chat/core/services/routes.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/src/messages/custom_message.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/packages/chat_ui/ttp_chat_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../features/chat/presentation/chat_provider.dart';
import '../../../packages/chat_core/ttp_chat_core.dart';
import '../../../theme/style.dart';
import 'chat_widgets/attachment_utils.dart';
import 'chat_widgets/chat_appbar.dart';
import 'chat_widgets/empty_message.dart';
import 'chat_widgets/order_message.dart';

class ChatPage extends StatelessWidget {
  final types.Room selectedChatRoom;

  const ChatPage(this.selectedChatRoom, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => ChatProvider.initialiseAndLoadMessages(selectedChatRoom),
      child: _ChatPage(selectedChatRoom),
    );
  }
}

class _ChatPage extends StatefulWidget {
  final types.Room selectedChatRoom;

  const _ChatPage(this.selectedChatRoom);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> with SingleTickerProviderStateMixin {
  late ChatProvider chatProvider;
  late AnimationController controller;
  late Animation<Offset> offset;
  Stream<List<types.Message>>? messageStream;
  bool showRecordingAnimation = false;

  /// hiding Input in two cases:
  /// 1. If The Account is Deleted from firebase
  /// 2. If the Room is Channel and the current user is not the owner of room
  bool get hideInput {
    if (chatProvider.selectedChatRoom?.type == types.RoomType.channel) {
      return chatProvider.selectedChatRoom?.owner != FirebaseAuth.instance.currentUser?.uid;
    } else {
      return (chatProvider.selectedChatRoom!.userIds.any((id) => (id == 'deleted-brand' || id == 'deleted-user')));
    }
  }

  void _handleVoiceMessagePressed() {
    setState(() => showRecordingAnimation = true);
    controller.forward();
    chatProvider.startRecording();
    chatProvider.startWaveFormAnimation();
  }

  void _handleOnMessageContentPressed(types.Message message, String text) async {
    if (RegExp(r'@(\w+)').hasMatch(text)) {
      // Handle @mentions
      if (GetIt.I<ChatUtils>().isCreatorsApp) {
        final username = text.replaceFirst('@', '');
        final link = await DeeplinkBuilder.buildCreatorProfileLink(username: username);

        if (link == null) {
          return;
        }

        launchUrl(link, mode: LaunchMode.externalApplication);
      } else {
        Routes.navigateToOutletPage(context, text.replaceFirst('@', ''));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    messageStream = FirebaseChatCore.instance.messages(widget.selectedChatRoom);
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    offset = Tween<Offset>(begin: const Offset(-2.0, 0.0), end: Offset.zero).animate(controller);
    ChatUtils.updateUnreadMessageStatus(chatProvider);
  }

  @override
  void dispose() {
    super.dispose();
    chatProvider.disposeTimer();
  }

  @override
  Widget build(BuildContext context) {
    chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatRoomAppBar(chatProvider),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StreamBuilder<List<types.Message>>(
          initialData: const [],
          stream: messageStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            final messages = addIsLastOrderMessageProperty(snapshot.data ?? []);

            return Stack(
              children: [
                Chat(
                  messages: messages,
                  dateFormat: DateFormat('dd MMM'),
                  dateLocale: '',
                  timeFormat: DateFormat('hh:mm a'),
                  isLastPage: false,
                  onEndReached: () async {
                    debugPrint('END');
                  },
                  onEndReachedThreshold: 10.0,
                  onTextChanged: (String value) {},
                  isAttachmentUploading: chatProvider.isAttachmentUploading,
                  onAttachmentPressed: () => handleAttachmentPressed(context, chatProvider: chatProvider),
                  onVoiceMessagePressed: _handleVoiceMessagePressed,
                  onMessageTap: chatProvider.handleFBMessageTap,
                  onMessageContentPressed: _handleOnMessageContentPressed,
                  onPreviewDataFetched: chatProvider.handleFBPreviewDataFetched,
                  onSendPressed: chatProvider.handleFBSendPressed,
                  hideInput: hideInput,
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser!.uid,
                  ),
                  buildCustomMessage: (message) => OrderMessage(message as CustomMessage),
                  onMessageLongPress: (message) {},
                  showUserAvatars: true,
                  theme: DefaultChatTheme(
                    dateDividerTextStyle: Ts.fpCaps(Config.grayG2Color),
                    messageBorderRadius: L.v(5),
                    backgroundColor: ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor,
                    primaryColor: Config.successGreenColor,
                    secondaryColor: Config.grayG4Color,
                    inputTextColor: Config.blackColor,
                    inputTextStyle: Ts.t2Reg(Config.blackColor),
                    sentMessageBodyTextStyle: Ts.t2Reg(Config.creameryColor),
                    sentMessageCaptionTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    sentMessageLinkTitleTextStyle: const TextStyle(color: Colors.white),
                    sentMessageLinkDescriptionTextStyle:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    receivedMessageBodyTextStyle: Ts.t2Reg(Config.blackColor),
                    receivedMessageCaptionTextStyle:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    receivedMessageLinkTitleTextStyle: const TextStyle(color: Colors.white),
                    receivedMessageLinkDescriptionTextStyle:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    sentMessageDocumentIconColor: Colors.white,
                    receivedMessageDocumentIconColor: Colors.white,
                  ),
                  emptyState: EmptyMessage(chatProvider: chatProvider),
                  customDateHeaderText: (DateTime dateTime) {
                    return DateFormat('dd MMM  •  hh:mm a').format(dateTime).toUpperCase();
                  },
                ),
                if (showRecordingAnimation)
                  RecordingAnimation(offset: offset, chatProvider: chatProvider, controller: controller)
              ],
            );
          },
        ),
      ),
    );
  }
}
