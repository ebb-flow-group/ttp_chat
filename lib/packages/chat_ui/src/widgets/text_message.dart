import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_text/chat_text.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/packages/link_previewer/flutter_link_previewer.dart';
import 'package:ttp_chat/packages/link_previewer/src/utils.dart';

import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents text message widget with optional link preview
class TextMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.TextMessage] class
  const TextMessage({
    Key? key,
    @required this.message,
    this.onPreviewDataFetched,
    @required this.usePreviewData,
    @required this.showName,
    this.onMessageContentPressed,
  }) : super(key: key);

  /// [types.TextMessage]
  final types.TextMessage? message;

  /// See [LinkPreview.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)? onPreviewDataFetched;

  /// Show user name for the received message. Useful for a group chat.
  final bool? showName;

  /// Enables link (URL) preview
  final bool? usePreviewData;

  /// See [Message.onMessageContentPressed]
  final void Function(types.TextMessage, String text)? onMessageContentPressed;

  void _onPreviewDataFetched(types.PreviewData previewData) {
    if (message!.previewData == null) {
      onPreviewDataFetched?.call(message!, previewData);
    }
  }

  Widget _linkPreview(
    types.User user,
    double width,
    BuildContext context,
  ) {
    final bodyTextStyle = user.id == message!.author.id
        ? InheritedChatTheme.of(context)!.theme!.sentMessageBodyTextStyle
        : InheritedChatTheme.of(context)!.theme!.receivedMessageBodyTextStyle;
    final linkDescriptionTextStyle = user.id == message!.author.id
        ? InheritedChatTheme.of(context)!.theme!.sentMessageLinkDescriptionTextStyle
        : InheritedChatTheme.of(context)!.theme!.receivedMessageLinkDescriptionTextStyle;
    final linkTitleTextStyle = user.id == message!.author.id
        ? InheritedChatTheme.of(context)!.theme!.sentMessageLinkTitleTextStyle
        : InheritedChatTheme.of(context)!.theme!.receivedMessageLinkTitleTextStyle;

    final color = getUserAvatarNameColor(message!.author, InheritedChatTheme.of(context)!.theme!.userAvatarNameColors!);
    final name = getUserName(message!.author);

    return LinkPreview(
      enableAnimation: true,
      header: showName! ? name : null,
      headerStyle: InheritedChatTheme.of(context)!.theme!.userNameTextStyle!.copyWith(color: color),
      linkStyle: bodyTextStyle,
      metadataTextStyle: linkDescriptionTextStyle,
      metadataTitleStyle: linkTitleTextStyle,
      onPreviewDataFetched: _onPreviewDataFetched,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 16,
      ),
      previewData: message!.previewData,
      text: message!.text,
      textStyle: bodyTextStyle,
      width: width,
    );
  }

  Widget _textWidget(types.User user, BuildContext context) {
    final color = getUserAvatarNameColor(message!.author, InheritedChatTheme.of(context)!.theme!.userAvatarNameColors!);
    final name = getUserName(message!.author);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName!)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: InheritedChatTheme.of(context)!.theme!.userNameTextStyle!.copyWith(color: color),
            ),
          ),
        ChatText(
          text: message!.text,
          style: user.id == message!.author.id
              ? InheritedChatTheme.of(context)!.theme!.sentMessageBodyTextStyle
              : InheritedChatTheme.of(context)!.theme!.receivedMessageBodyTextStyle,
          highlightRegex: RegExp(r'@(\w+)'),
          highlightStyle: (baseStyle, text, index) => user.id == message!.author.id
              ? InheritedChatTheme.of(context)!.theme!.sentMessageBodyTextStyle?.copyWith(fontWeight: FontWeight.w800)
              : InheritedChatTheme.of(context)!
                  .theme!
                  .receivedMessageBodyTextStyle
                  ?.copyWith(fontWeight: FontWeight.w800),
          onHighlightPressed: (text, index) {
            onMessageContentPressed?.call(message!, text);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = InheritedUser.of(context)!.user;
    final width = MediaQuery.of(context).size.width;

    final urlRegexp = RegExp(regexLink);
    final matches = urlRegexp.allMatches(message!.text.toLowerCase());

    if (matches.isNotEmpty && usePreviewData! && onPreviewDataFetched != null) {
      return _linkPreview(user!, width, context);
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: _textWidget(user!, context),
    );
  }
}
