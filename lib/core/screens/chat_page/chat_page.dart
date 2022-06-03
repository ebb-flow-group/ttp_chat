import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/loading_screen.dart';
import 'package:ttp_chat/core/services/ts.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/packages/chat_ui/ttp_chat_ui.dart';

import '../../../packages/chat_core/ttp_chat_core.dart';
import '../../../theme/style.dart';
import 'chat_widgets/attachment_utils.dart';
import 'chat_widgets/chat_appbar.dart';
import 'chat_widgets/empty_message.dart';
import 'chat_widgets/order_message_widget.dart';
import 'store/chat_page_state.dart';

class ChatPage extends StatefulWidget {
  final types.Room chatRoom;

  const ChatPage(this.chatRoom, {Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> offset;
  Stream<List<types.Message>>? messageStream;
  bool showRecordingAnimation = false;
  ChatPageState state = ChatPageState();

  @override
  void initState() {
    super.initState();
    state.init(widget.chatRoom);
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    offset = Tween<Offset>(begin: const Offset(-2.0, 0.0), end: Offset.zero).animate(controller);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatRoomAppBar(state.chatRoom),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: StreamBuilder<List<types.Message>>(
          initialData: const [],
          stream: messageStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            return Stack(
              children: [
                Chat(
                  messages: snapshot.data ?? [],
                  dateFormat: DateFormat('dd MMM'),
                  dateLocale: '',
                  timeFormat: DateFormat('hh:mm a'),
                  isLastPage: false,
                  onEndReached: () async {
                    debugPrint('END');
                  },
                  onEndReachedThreshold: 10.0,
                  onTextChanged: (String value) {},
                  isAttachmentUploading: state.isAttachmentUploading,
                  onAttachmentPressed: () => handleAttachmentPressed(context, state: state),
                  onVoiceMessagePressed: _handleVoiceMessagePressed,
                  onMessageTap: state.onMessageTap,
                  onPreviewDataFetched: state.handlePreviewDataFetched,
                  onSendPressed: state.sendMessage,
                  hideInput: hideInput,
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser!.uid,
                  ),
                  buildCustomMessage: (message) => OrderMessageWidget(message),
                  onMessageLongPress: (message) {},
                  showUserAvatars: true,
                  theme: DefaultChatTheme(
                    dateDividerTextStyle: Ts.demi11(Config.grayG2Color),
                    messageBorderRadius: 0.0,
                    backgroundColor: ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor,
                    primaryColor: Config.lightGrey,
                    secondaryColor: Theme.of(context).primaryColor,
                    inputTextColor: Theme.of(context).primaryColor,
                    sentMessageBodyTextStyle: Ts.text13(Config.primaryColor),
                    sentMessageCaptionTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    sentMessageLinkTitleTextStyle: const TextStyle(color: Colors.white),
                    sentMessageLinkDescriptionTextStyle:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    receivedMessageBodyTextStyle: Ts.text13(Config.creameryColor),
                    receivedMessageCaptionTextStyle:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    receivedMessageLinkTitleTextStyle: const TextStyle(color: Colors.white),
                    receivedMessageLinkDescriptionTextStyle:
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                    sentMessageDocumentIconColor: Colors.white,
                    receivedMessageDocumentIconColor: Colors.white,
                  ),
                  emptyState: EmptyMessage(chatRoom: state.chatRoom),
                  customDateHeaderText: (DateTime dateTime) {
                    return DateFormat('dd MMM  •  hh:mm a').format(dateTime).toUpperCase();
                  },
                ),
                // if (showRecordingAnimation)
                //   RecordingAnimation(offset: offset, chatProvider: chatProvider, controller: controller)
              ],
            );
          },
        ),
      ),
    );
  }

  /// hiding Input in two cases:
  /// 1. If The Account is Deleted from firebase
  /// 2. If the Room is Channel and the current user is not the owner of room
  bool get hideInput {
    if (state.chatRoom.type == types.RoomType.channel) {
      return state.chatRoom.owner != FirebaseAuth.instance.currentUser?.uid;
    } else {
      return (state.chatRoom.userIds.any((id) => (id == 'deleted-brand' || id == 'deleted-user')));
    }
  }

  _handleVoiceMessagePressed() {
    setState(() => showRecordingAnimation = true);
    controller.forward();
    // chatProvider.startRecording();
    // chatProvider.startWaveFormAnimation();
  }
}
