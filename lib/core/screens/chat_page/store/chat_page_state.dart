import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:mobx/mobx.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;

import '../../../../packages/chat_core/ttp_chat_core.dart';
import '../../../../utils/functions.dart';
import '../../chat_utils.dart';

part 'chat_page_state.g.dart';

class ChatPageState = _ChatPageState with _$ChatPageState;

abstract class _ChatPageState with Store {
  @readonly
  types.Room? _chatRoom;

  @readonly
  // ignore: prefer_final_fields
  bool _isAttachmentUploading = false;

  @observable
  Stream<List<types.Message>> messageStream = const Stream.empty();

  @action
  init(types.Room room) {
    _chatRoom = room;
    messageStream = FirebaseChatCore.instance.messages(room);
    ChatUtils.updateUnreadMessageStatus(room);
  }

  @action
  void sendMessage(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(message, _chatRoom);
  }

  @action
  void setAttachmentUploading(bool uploading) {
    _isAttachmentUploading = uploading;
  }

  @action
  Future<void> onMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      consoleLog('Local Path: $localPath');

      if (message.uri.startsWith('https')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getExternalStorageDirectory())!.path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }

      await OpenFile.open(localPath);
    } else if (message is types.VoiceMessage) {
      consoleLog('Voice Message Tapped');
    }
  }

  @action
  void handlePreviewDataFetched(types.TextMessage message, types.PreviewData previewData) {
    final updatedMessage = message.copyWith(previewData: previewData);
    FirebaseChatCore.instance.updateMessage(updatedMessage, _chatRoom!.id);
  }

  @action
  Future<void> pickAndSendImage() async {
    final result = await ImagePicker().pickImage(imageQuality: 70, maxWidth: 1440, source: ImageSource.gallery);

    if (result != null) {
      // setAttachmentUploading(true);

      final size = await result.length();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      String name = "";
      try {
        name = result.path.split('/').last;
      } catch (e) {
        name = "image.jpg";
      }

      try {
        final reference = FirebaseStorage.instance.ref(name);
        if (kIsWeb) {
          final metadata =
              SettableMetadata(contentType: 'image/jpeg', customMetadata: {'picked-file-path': result.path});
          await reference.putData(bytes, metadata);
        } else {
          final file = File(result.path);
          await reference.putFile(file);
        }

        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
            height: image.height.toDouble(), name: name, size: size, uri: uri, width: image.width.toDouble());

        FirebaseChatCore.instance.sendMessage(message, _chatRoom);
        setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        setAttachmentUploading(false);
        consoleLog(e.toString());
      }
    }
  }

  @action
  Future<void> pickandSendFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setAttachmentUploading(true);
      PlatformFile file = result.files.single;
      final name = file.name;
      final filePath = file.path;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        if (kIsWeb) {
          Uint8List? bytes = file.bytes;
          if (bytes == null) return;
          await reference.putData(bytes);
        } else {
          final file = File(filePath ?? '');
          await reference.putFile(file);
        }

        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath ?? ''),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, _chatRoom);
        setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        setAttachmentUploading(false);
        consoleLog(e.toString());
      }
    }
  }

  Future<void> handleSendVoiceMessagePressed() async {
    // if (voiceMessageFile != null) {
    //   setAttachmentUploading(true);
    //   final name = voiceMessageFile!.path.split('/').last;
    //   consoleLog('Audio File : $name');
    //   final filePath = voiceMessageFile?.path;
    //   consoleLog('Audio File Path: $filePath');
    //   final file = File(filePath ?? '');
    //   consoleLog('Audio File Size: ${voiceMessageFile!.lengthSync()}');

    //   try {
    //     final reference = FirebaseStorage.instance.ref(name);
    //     await reference.putFile(file);
    //     final uri = await reference.getDownloadURL();
    //     consoleLog('Audio Url: $uri');
    //     consoleLog('Audio Type: ${lookupMimeType(filePath ?? '')}');

    //     final message = types.PartialVoice(
    //         mimeType: lookupMimeType(filePath ?? ''),
    //         name: name,
    //         size: voiceMessageFile!.lengthSync(),
    //         uri: uri,
    //         duration: audioMessageDuration.inSeconds);

    //     FirebaseChatCore.instance.sendMessage(message, chatRoom);

    //     voiceMessageFile = null;
    //     voiceMessageFilePath = '';
    //     setAttachmentUploading(false);
    //   } on FirebaseException catch (e) {
    //     voiceMessageFile = null;
    //     voiceMessageFilePath = '';
    //     setAttachmentUploading(false);
    //     consoleLog(e.toString());
    //   }
    // }
  }
}
