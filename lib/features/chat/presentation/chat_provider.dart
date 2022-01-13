import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import '../../../models/base_model.dart';
import '../../../network/api_service.dart';
import '../../../packages/chat_core/ttp_chat_core.dart';
import '../../../utils/functions.dart';
import '../domain/brand_firebase_token_model.dart';
import '../domain/user_firebase_token_model.dart';

enum ApiStatus { called, success, failed }

class ChatProvider extends ChangeNotifier {
  types.User? user;
  FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder();
  FlutterSoundPlayer flutterSoundPlayer = FlutterSoundPlayer();
  List<types.Message> messagesList = [];
  Codec _codec = Codec.aacMP4;
  String voiceMessageFilePath = '';
  bool isRecording = false;
  types.VoiceMessage? recordedVoiceMessage;
  File? voiceMessageFile;
  int? recordedVoiceMessageFileDuration;
  Duration? audioMessageDuration;
  Timer? audioMessageTimer;
  bool isRecordedVoiceMessageFilePlaying = false;
  bool isAttachmentUploading = false;
  List<double> waveFormList = [];
  Timer? waveFormTimer;
  ScrollController controller = ScrollController();
  GlobalKey<AnimatedListState>? waveFormListKey;

  ApiStatus apiStatus = ApiStatus.called;
  // FB Integration Variables
  types.Room? selectedChatUser;

  int selectedTabIndex = 0, brandListCount = 0, userListCount = 0;
  bool isRoomListEmpty = false;
  String? accessToken, refreshToken;

  List<types.Room> roomList = [];

  getLocalRoomList() {
    SharedPreferences.getInstance().then((prefs) {
      var data = prefs.getString("roomList");
      if (data != null) {
        List roomListCache = json.decode(data);
        roomList = roomListCache.map((e) => types.Room.fromJson(e)).toList();
        notifyListeners();
      }
    });
  }

  ChatProvider.userSignIn(bool isSwitchedAccount, this.accessToken, this.refreshToken) {
    selectedTabIndex = 0;
    if (FirebaseAuth.instance.currentUser == null) {
      consoleLog('CURRENT USER IS NULL');
      getUserFirebaseToken(accessToken!);
    } else {
      // FirebaseAuth.instance.currentUser!.reload();
      getCountData();
      apiStatus = ApiStatus.success;
      notifyListeners();
      consoleLog('CURRENT USER IS NOT NULL');
    }
  }

  ChatProvider.brandSignIn(bool isSwitchedAccount, this.accessToken, this.refreshToken) {
    selectedTabIndex = 0;
    if (FirebaseAuth.instance.currentUser == null) {
      getBrandFirebaseToken(accessToken!);
      consoleLog('CURRENT BRAND IS NULL');
    } else {
      // FirebaseAuth.instance.currentUser!.reload();
      getCountData();
      apiStatus = ApiStatus.success;
      notifyListeners();
      consoleLog('CURRENT BRAND IS NOT NULL');
    }
  }

  void userCustomFirebaseTokenSignIn(String firebaseToken) async {
    consoleLog('USER FIREBASE TOKEN 1: $firebaseToken');
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      consoleLog('UserId: ${userCredential.user!.uid}');
      //  checkIfUserIsBrandOrUser(userCredential.user!.uid);
      getCountData();
      // createUserOnFirestore(chatSignInModel, userCredential.user!.uid);
      apiStatus = ApiStatus.success;
      notifyListeners();
    } catch (e, s) {
      consoleLog('USER CUSTOM FIREBASE TOKEN SIGN IN ERROR: $e\n$s');
    }
  }

  void brandCustomFirebaseTokenSignIn(List<BrandFirebaseTokenData> brandsList) async {
    consoleLog('SECONDARY FB APP');
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(brandsList[0].firebaseToken!);
      consoleLog('UserId: ${userCredential.user!.uid}');
      //   checkIfUserIsBrandOrUser(userCredential.user!.uid);
      getCountData();
      apiStatus = ApiStatus.success;
      notifyListeners();
    } catch (e, s) {
      consoleLog('BRAND CUSTOM FIREBASE TOKEN SIGN IN ERROR: $e\n$s');
    }
  }

  void updateTabIndex(int value) {
    selectedTabIndex = value;
    notifyListeners();
  }

  // void checkIfUserIsBrandOrUser(String uid) async {
  //   final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

  //   final data = snapshot.data();
  //   consoleLog('USER TYPE: ${data!['user_type']}');
  //   if (data['user_type'] == 'brand') {
  //     isBrand = true;
  //   } else if (data['user_type'] == 'user') {
  //     isBrand = false;
  //   }
  //   notifyListeners();
  // }

  void getUserFirebaseToken(String accessToken) async {
    consoleLog('ACCESS TOKEN 1: $accessToken');
    BaseModel<UserFirebaseTokenModel> response = await GetIt.I<ApiService>().getUserFirebaseToken(accessToken);
    if (response.data != null) {
      consoleLog('USER FIREBASE TOKEN 1: ${response.data!.firebaseToken!}');
      userCustomFirebaseTokenSignIn(response.data!.firebaseToken!);
    } else {
      apiStatus = ApiStatus.failed;
      notifyListeners();
      consoleLog('CUSTOM SIGN IN ERROR: ${response.getException.getErrorMessage()}');
    }
  }

  void getBrandFirebaseToken(String accessToken) async {
    consoleLog('ACCESS TOKEN 1: $accessToken');
    BaseModel<BrandFirebaseTokenModel> response = await GetIt.I<ApiService>().getBrandFirebaseToken(accessToken);
    if (response.data != null) {
      consoleLog('BRAND FIREBASE TOKEN 1: ${response.data!.toJson()}');
      if (response.data!.brandFirebaseTokenList!.isEmpty || response.data!.brandFirebaseTokenList!.length > 1) {
        apiStatus = ApiStatus.failed;
        notifyListeners();
      } else {
        brandCustomFirebaseTokenSignIn(response.data!.brandFirebaseTokenList!);
      }
    } else {
      apiStatus = ApiStatus.failed;
      notifyListeners();
      consoleLog('CUSTOM SIGN IN ERROR: ${response.getException.getErrorMessage()}');
    }
  }

  void getCountData() {
    notifyListeners();
    FirebaseChatCore.instance.rooms().listen((event) {
      notifyListeners();
      if (event.isEmpty) {
        isRoomListEmpty = true;
        notifyListeners();
      } else {
        brandListCount = event.where((element) => element.metadata!['other_user_type'] == 'brand').toList().length;
        userListCount = event.where((element) => element.metadata!['other_user_type'] == 'user').toList().length;
        notifyListeners();
      }
    });
  }

  void startRecording() async {
    bool result = await Record().hasPermission();

    if (result) {
      Directory voiceMessageDirectory = await getApplicationDocumentsDirectory();

      consoleLog('APP APPLE DOCS DIRE: ${voiceMessageDirectory.path}');

      voiceMessageFilePath = '';
      voiceMessageFilePath = '${voiceMessageDirectory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4';

      consoleLog('APP APPLE DOCS DIRE: $voiceMessageFilePath');

      await Record().start(
        path: voiceMessageFilePath,
        encoder: AudioEncoder.AAC,
        bitRate: 128000,
        samplingRate: 44100,
      );
    } else {
      //get permission
    }

    isRecording = true;

    notifyListeners();
  }

  void stopRecording() async {
    isRecording = false;
    consoleLog('VOICE MESSAGE FILE PATH: $voiceMessageFilePath');
    await Record().stop();

    voiceMessageFile = File(voiceMessageFilePath);
    audioMessageDuration = await FlutterSoundHelper().duration(voiceMessageFilePath);

    consoleLog('DURATION FOR METADATA: ${audioMessageDuration!.inSeconds}');

    recordedVoiceMessageFileDuration = audioMessageDuration!.inSeconds;

    recordedVoiceMessage = null;

    recordedVoiceMessage = types.VoiceMessage(
        author: user ??
            types.User(
              id: FirebaseAuth.instance.currentUser!.uid,
            ),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(voiceMessageFilePath),
        name: voiceMessageFilePath.split('/').last,
        size: File(voiceMessageFilePath).lengthSync(),
        uri: voiceMessageFilePath,
        duration: Duration.zero.inSeconds);

    consoleLog('METADATA: ${recordedVoiceMessage!.metadata}');

    handleSendVoiceMessagePressed();

    notifyListeners();
  }

  void startWaveFormAnimation() {
    waveFormListKey = GlobalKey();
    const oneSec = Duration(milliseconds: 400);
    waveFormList.clear();
    waveFormTimer = Timer.periodic(oneSec, (Timer t) {
      waveFormList.add(Random().nextInt(46).toDouble());
      waveFormListKey!.currentState?.insertItem(waveFormList.length - 1);
      controller.animateTo(controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      notifyListeners();
    });
    notifyListeners();
  }

  void stopWaveFormAnimation() {
    // if(waveFormListKey.currentState.mounted) waveFormListKey.currentState.dispose();
    waveFormTimer!.cancel();
  }

  void disposeAudioMessageTimer() {
    if (audioMessageTimer != null) audioMessageTimer!.cancel();
  }

  void removeRecordedVoiceMessage() async {
    await Record().stop();
    voiceMessageFile = null;
    voiceMessageFilePath = '';
    isRecordedVoiceMessageFilePlaying = false;
    // audioPlayer.stop();
    // audioPlayer.dispose();
    notifyListeners();
  }

  void openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }

      var storageStatus = await Permission.storage.request();
      if (storageStatus != PermissionStatus.granted) {
        throw Exception('Storage permission not granted');
      }
    }
    await flutterSoundRecorder.openAudioSession();
    if (!await flutterSoundRecorder.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.aacMP4;
      //  _mPath = DateTime.now().millisecondsSinceEpoch.toString();
      if (!await flutterSoundRecorder.isEncoderSupported(_codec) && kIsWeb) {
        return;
      }
    }
  }

  void handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: user!,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.path.split('/').last,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
      addMessage(message);
    }
  }

  void handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      final message = types.FileMessage(
        author: user!,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path ?? ''),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path ?? '',
      );

      addMessage(message);
    }
  }

  void handlePreviewDataFetched(types.TextMessage message, types.PreviewData previewData) {
    final index = messagesList.indexWhere((element) => element.id == message.id);
    final updatedMessage = messagesList[index].copyWith(previewData: previewData);

    messagesList[index] = updatedMessage;
    notifyListeners();
  }

  void handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: user!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    addMessage(textMessage);
  }

  void addMessage([types.Message? message]) {
    messagesList.insert(0, message!);
    consoleLog('MESSAGE LIST LENGTH: ${messagesList.length}');
    notifyListeners();
  }

  void addVoiceMessage() {
    addMessage(recordedVoiceMessage);
    isRecordedVoiceMessageFilePlaying = false;
    voiceMessageFile = null;
    voiceMessageFilePath = '';
    notifyListeners();
  }

  ChatProvider.initialiseAndLoadMessages(this.selectedChatUser) {
    notifyListeners();
  }

  void setAttachmentUploading(bool uploading) {
    isAttachmentUploading = uploading;
    notifyListeners();
  }

  void handleFBSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(message, selectedChatUser!.id);
  }

  void handleFBMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      consoleLog('LOCAL PATH: $localPath');

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
      Duration? duration = await FlutterSoundHelper().duration(message.uri);
      consoleLog('ON TAP DURATION: $duration');
    }
  }

  void handleFBPreviewDataFetched(types.TextMessage message, types.PreviewData previewData) {
    final updatedMessage = message.copyWith(previewData: previewData);
    FirebaseChatCore.instance.updateMessage(updatedMessage, selectedChatUser!.id);
  }

  void handleFBImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.path.split('/').last;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          selectedChatUser!.id,
        );
        setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        setAttachmentUploading(false);
        consoleLog(e.toString());
      }
    }
  }

  void handleFBFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null) {
      setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path;
      final file = File(filePath ?? '');

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath ?? ''),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, selectedChatUser!.id);
        setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        setAttachmentUploading(false);
        consoleLog(e.toString());
      }
    }
  }

  void handleSendVoiceMessagePressed() async {
    if (voiceMessageFile != null) {
      setAttachmentUploading(true);
      final name = voiceMessageFile!.path.split('/').last;
      consoleLog('VOICE MESSAGE FILE NAME: $name');
      final filePath = voiceMessageFile?.path;
      consoleLog('VOICE MESSAGE FILE PATH: $filePath');
      final file = File(filePath ?? '');
      consoleLog('VOICE MESSAGE FILE: $file');
      consoleLog('VOICE MESSAGE FILE SIZE: ${voiceMessageFile!.lengthSync()}');

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();
        consoleLog('VOICE MESSAGE FILE FB STORAGE URL: $uri');
        consoleLog('VOICE MESSAGE FILE MIME TYPE: ${lookupMimeType(filePath ?? '')}');

        final message = types.PartialVoice(
            mimeType: lookupMimeType(filePath ?? ''),
            name: name,
            size: voiceMessageFile!.lengthSync(),
            uri: uri,
            duration: audioMessageDuration!.inSeconds);

        FirebaseChatCore.instance.sendMessage(message, selectedChatUser!.id);
        isRecordedVoiceMessageFilePlaying = false;
        voiceMessageFile = null;
        voiceMessageFilePath = '';
        setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        isRecordedVoiceMessageFilePlaying = false;
        voiceMessageFile = null;
        voiceMessageFilePath = '';
        setAttachmentUploading(false);
        consoleLog(e.toString());
      }
    }
  }
}
