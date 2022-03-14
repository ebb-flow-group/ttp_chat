import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ttp_chat/config.dart';
import 'package:ttp_chat/core/screens/chat_page/chat_widgets/recording_animation.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/packages/chat_ui/ttp_chat_ui.dart';

import '../../../features/chat/presentation/chat_provider.dart';
import '../../../packages/chat_core/ttp_chat_core.dart';
import '../../../theme/style.dart';
import 'chat_widgets/attachment_utils.dart';
import 'chat_widgets/chat_appbar.dart';
import 'chat_widgets/empty_message.dart';
import 'chat_widgets/order_message_widget.dart';

class ChatPage extends StatelessWidget {
  final types.Room selectedChatRoom;

  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const ChatPage(this.selectedChatRoom, this.onViewOrderDetailsClick, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChatProvider>(
      create: (context) => ChatProvider.initialiseAndLoadMessages(selectedChatRoom),
      child: _ChatPage(selectedChatRoom, onViewOrderDetailsClick),
    );
  }
}

class _ChatPage extends StatefulWidget {
  final types.Room selectedChatRoom;
  final Function(int?, String?, String?)? onViewOrderDetailsClick;

  const _ChatPage(this.selectedChatRoom, this.onViewOrderDetailsClick);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<_ChatPage> with SingleTickerProviderStateMixin {
  late ChatProvider chatProvider;
  late AnimationController controller;
  late Animation<Offset> offset;
  Stream<List<types.Message>>? messageStream;
  bool showRecordingAnimation = false;

  @override
  void initState() {
    super.initState();
    chatProvider = context.read<ChatProvider>();
    messageStream = FirebaseChatCore.instance.messages(widget.selectedChatRoom);
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    offset = Tween<Offset>(begin: const Offset(-2.0, 0.0), end: Offset.zero).animate(controller);
    ChatUtils().updateUnreadMessageStatus(chatProvider);
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
      appBar: ChatAppBar(chatProvider),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: messageStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator(color: Config.primaryColor);
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
                    isAttachmentUploading: chatProvider.isAttachmentUploading,
                    onAttachmentPressed: () => handleAttachmentPressed(context, chatProvider: chatProvider),
                    onVoiceMessagePressed: _handleVoiceMessagePressed,
                    onMessageTap: chatProvider.handleFBMessageTap,
                    onPreviewDataFetched: chatProvider.handleFBPreviewDataFetched,
                    onSendPressed: chatProvider.handleFBSendPressed,
                    hideInput: chatProvider.selectedChatRoom!.userIds
                        .any((id) => (id == 'deleted-brand' || id == 'deleted-user')),
                    user: types.User(
                      id: FirebaseChatCore.instance.firebaseUser!.uid,
                    ),
                    buildCustomMessage: (message) => OrderMessageWidget(message),
                    onMessageLongPress: (message) {},
                    showUserAvatars: false,
                    theme: DefaultChatTheme(
                      messageBorderRadius: 0.0,
                      backgroundColor: ThemeUtils.defaultAppThemeData.scaffoldBackgroundColor,
                      primaryColor: Theme.of(context).colorScheme.secondary,
                      secondaryColor: Theme.of(context).primaryColor,
                      inputTextColor: Theme.of(context).primaryColor,
                      sentMessageBodyTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                      sentMessageCaptionTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                      sentMessageLinkTitleTextStyle: const TextStyle(color: Colors.white),
                      sentMessageLinkDescriptionTextStyle:
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                      receivedMessageBodyTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
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
                      return DateFormat('dd MMM | hh:mm a').format(dateTime).toUpperCase();
                    },
                  ),
                  if (showRecordingAnimation)
                    RecordingAnimation(offset: offset, chatProvider: chatProvider, controller: controller)
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _handleVoiceMessagePressed() {
    setState(() => showRecordingAnimation = true);
    controller.forward();
    chatProvider.startRecording();
    chatProvider.startWaveFormAnimation();
  }
}
