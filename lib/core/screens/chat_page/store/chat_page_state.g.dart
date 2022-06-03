// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_page_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$ChatPageState on _ChatPageState, Store {
  late final _$_chatRoomAtom =
      Atom(name: '_ChatPageState._chatRoom', context: context);

  types.Room get chatRoom {
    _$_chatRoomAtom.reportRead();
    return super._chatRoom;
  }

  @override
  types.Room get _chatRoom => chatRoom;

  @override
  set _chatRoom(types.Room value) {
    _$_chatRoomAtom.reportWrite(value, super._chatRoom, () {
      super._chatRoom = value;
    });
  }

  late final _$_isAttachmentUploadingAtom =
      Atom(name: '_ChatPageState._isAttachmentUploading', context: context);

  bool get isAttachmentUploading {
    _$_isAttachmentUploadingAtom.reportRead();
    return super._isAttachmentUploading;
  }

  @override
  bool get _isAttachmentUploading => isAttachmentUploading;

  @override
  set _isAttachmentUploading(bool value) {
    _$_isAttachmentUploadingAtom
        .reportWrite(value, super._isAttachmentUploading, () {
      super._isAttachmentUploading = value;
    });
  }

  late final _$messageStreamAtom =
      Atom(name: '_ChatPageState.messageStream', context: context);

  @override
  Stream<List<types.Message>> get messageStream {
    _$messageStreamAtom.reportRead();
    return super.messageStream;
  }

  @override
  set messageStream(Stream<List<types.Message>> value) {
    _$messageStreamAtom.reportWrite(value, super.messageStream, () {
      super.messageStream = value;
    });
  }

  late final _$onMessageTapAsyncAction =
      AsyncAction('_ChatPageState.onMessageTap', context: context);

  @override
  Future onMessageTap(types.Message message) {
    return _$onMessageTapAsyncAction.run(() => super.onMessageTap(message));
  }

  late final _$pickAndSendImageAsyncAction =
      AsyncAction('_ChatPageState.pickAndSendImage', context: context);

  @override
  Future pickAndSendImage() {
    return _$pickAndSendImageAsyncAction.run(() => super.pickAndSendImage());
  }

  late final _$pickandSendFileAsyncAction =
      AsyncAction('_ChatPageState.pickandSendFile', context: context);

  @override
  Future pickandSendFile() {
    return _$pickandSendFileAsyncAction.run(() => super.pickandSendFile());
  }

  late final _$_ChatPageStateActionController =
      ActionController(name: '_ChatPageState', context: context);

  @override
  dynamic init(types.Room room) {
    final _$actionInfo = _$_ChatPageStateActionController.startAction(
        name: '_ChatPageState.init');
    try {
      return super.init(room);
    } finally {
      _$_ChatPageStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void sendMessage(types.PartialText message) {
    final _$actionInfo = _$_ChatPageStateActionController.startAction(
        name: '_ChatPageState.sendMessage');
    try {
      return super.sendMessage(message);
    } finally {
      _$_ChatPageStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setAttachmentUploading(bool uploading) {
    final _$actionInfo = _$_ChatPageStateActionController.startAction(
        name: '_ChatPageState.setAttachmentUploading');
    try {
      return super.setAttachmentUploading(uploading);
    } finally {
      _$_ChatPageStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  void handlePreviewDataFetched(
      types.TextMessage message, types.PreviewData previewData) {
    final _$actionInfo = _$_ChatPageStateActionController.startAction(
        name: '_ChatPageState.handlePreviewDataFetched');
    try {
      return super.handlePreviewDataFetched(message, previewData);
    } finally {
      _$_ChatPageStateActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
messageStream: ${messageStream}
    ''';
  }
}
