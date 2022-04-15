import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ttp_chat/core/services/extensions.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

import '../../../core/screens/chat_utils.dart';
import '../../../global.dart';
import '../../../models/base_model.dart';
import '../../../models/brand_model.dart';
import '../../../network/api_service.dart';
import '../../../packages/chat_core/ttp_chat_core.dart';
import '../../../utils/functions.dart';
import '../domain/brand_firebase_token_model.dart';
import '../domain/user_firebase_token_model.dart';

enum ApiStatus { called, success, failed }

class ChatProvider extends ChangeNotifier {
  String searchString = '';
  types.User? user;
  List<types.Message> messagesList = [];
  String voiceMessageFilePath = '';
  bool isRecording = false;
  types.VoiceMessage? recordedVoiceMessage;
  File? voiceMessageFile;
  Duration audioMessageDuration = const Duration(seconds: 0);
  bool isAttachmentUploading = false;
  List<double> waveFormList = [];
  Timer? waveFormTimer;
  ScrollController controller = ScrollController();
  GlobalKey<AnimatedListState>? waveFormListKey;

  Stream<List<types.Room>> roomsStream = FirebaseChatCore.instance.rooms(orderByUpdatedAt: true);

  updateStream() {
    roomsStream = FirebaseChatCore.instance.rooms(orderByUpdatedAt: true);
    notifyListeners();
  }

  ApiStatus apiStatus = ApiStatus.called;
  types.Room? selectedChatRoom;

  int selectedTabIndex = 0;
  bool isRoomListEmpty = false;
  String? accessToken, refreshToken;

  searchUsers(String s) {
    searchString = s;
    notifyListeners();
  }

  //! To get the duration of the recorded audio
  Timer? recorderTimer;
  startTimer() {
    audioMessageDuration = const Duration(seconds: 0);
    recorderTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      Record().isRecording().then((running) {
        if (running) {
          audioMessageDuration = audioMessageDuration + const Duration(seconds: 1);
          consoleLog("Recorder running for ${audioMessageDuration.inSeconds} seconds");
        } else {
          consoleLog('Recorder Stopped');
          if (recorderTimer != null) recorderTimer!.cancel();
        }
      });
    });
  }

  disposeTimer() {
    Record().stop();
    if (recorderTimer != null) {
      recorderTimer!.cancel();
    }
    if (waveFormTimer != null) {
      waveFormTimer!.cancel();
    }
  }

//Not Used Now: Getting Rooms List from local storage
  // getLocalRoomList() {
  //   SharedPreferences.getInstance().then((prefs) {
  //     var data = prefs.getString("roomList");
  //     if (data != null) {
  //       List roomListCache = json.decode(data);
  //       roomList = roomListCache.map((e) => types.Room.fromJson(e)).toList();
  //       notifyListeners();
  //     }
  //   });
  // }

  // updateRoomList(List<types.Room> list) {
  //   roomList = list;
  //   notifyListeners();
  // }

  ChatProvider.userSignIn(this.accessToken, this.refreshToken) {
    selectedTabIndex = 0;
    if (FirebaseAuth.instance.currentUser == null) {
      consoleLog('User is not signed in');
      getUserFirebaseToken(accessToken!);
    } else {
      // FirebaseAuth.instance.currentUser!.reload();
      apiStatus = ApiStatus.success;
      notifyListeners();
      consoleLog('User is signed in ${FirebaseAuth.instance.currentUser!.uid}');
    }
  }

  ChatProvider.brandSignIn(this.accessToken, this.refreshToken) {
    selectedTabIndex = 0;
    if (FirebaseAuth.instance.currentUser == null) {
      getBrandFirebaseToken(accessToken!);
      consoleLog('Brand is not signed in');
    } else {
      // FirebaseAuth.instance.currentUser!.reload();
      apiStatus = ApiStatus.success;
      notifyListeners();
      consoleLog('Brand is signed in ${FirebaseAuth.instance.currentUser!.uid}');
    }
  }

  void userCustomFirebaseTokenSignIn(String firebaseToken) async {
    consoleLog('User Token : $firebaseToken');
    try {
      // consoleLog("---------------------------------");
      // consoleLog(Firebase.app().name);
      // consoleLog(Firebase.apps.first.name);

      // consoleLog("---------------------------------");
      // for (var app in Firebase.apps) {
      //   consoleLog(app.name);
      //   try {
      //     await FirebaseAuth.instanceFor(app: app).signInWithCustomToken(firebaseToken);
      //   } catch (e) {
      //     consoleLog("error");
      //   }
      // }

      // consoleLog("---------------------------------");
      UserCredential userCredential =
          await FirebaseAuth.instanceFor(app: Firebase.apps.first).signInWithCustomToken(firebaseToken);
      consoleLog('UserId: ${userCredential.user!.uid}');
      apiStatus = ApiStatus.success;
      updateStream();
      notifyListeners();
    } catch (e, s) {
      apiStatus = ApiStatus.failed;
      notifyListeners();
      consoleLog('Firebase Token SignIn Error: $e\n$s');
    }
  }

  void brandCustomFirebaseTokenSignIn(List<BrandFirebaseTokenData> brandsList) async {
    String firebaseToken = '';
    if (brandsList.isNotEmpty) {
      firebaseToken = brandsList.first.firebaseToken ?? "";
    }

    // Getting Active brand saved locally
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Brand? brand = prefs.getString(activeBrand)?.toBrand;

    // Making Room List empty to avoid rooms of another brand
    GetIt.I<ChatUtils>().updateRoomList([]);

    //checking if the active brand is available in the list
    if (brand != null) {
      for (var element in brandsList) {
        if (element.brandName == brand.name) {
          firebaseToken = element.firebaseToken ?? "";
        }
      }
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      consoleLog('UserId: ${userCredential.user!.uid}');
      apiStatus = ApiStatus.success;
      updateStream();
      notifyListeners();
    } catch (e, s) {
      apiStatus = ApiStatus.failed;
      notifyListeners();
      consoleLog('Firebase Token SignIn Error: $e\n$s');
    }
  }

  void updateTabIndex(int value) {
    selectedTabIndex = value;
    notifyListeners();
  }

  void getUserFirebaseToken(String accessToken) async {
    consoleLog('Access Token : $accessToken');
    BaseModel<UserFirebaseTokenModel> response = await ApiService().getUserFirebaseToken(accessToken);
    if (response.data != null) {
      consoleLog('User Firebase Token : ${response.data!.firebaseToken!}');
      userCustomFirebaseTokenSignIn(response.data!.firebaseToken!);
    } else {
      apiStatus = ApiStatus.failed;
      notifyListeners();
      consoleLog('SignIn Error: ${response.getException.getErrorMessage()}');
    }
  }

  void getBrandFirebaseToken(String accessToken) async {
    consoleLog('Access Token : $accessToken');
    BaseModel<BrandFirebaseTokenModel> response = await ApiService().getBrandFirebaseToken(accessToken);
    if (response.data != null) {
      if (response.data!.brandFirebaseTokenList?.isEmpty == true) {
        apiStatus = ApiStatus.failed;
        notifyListeners();
      } else {
        brandCustomFirebaseTokenSignIn(response.data?.brandFirebaseTokenList ?? []);
      }
    } else {
      apiStatus = ApiStatus.failed;
      notifyListeners();
      consoleLog('SignIn Error: ${response.getException.getErrorMessage()}');
    }
  }

  void startRecording() async {
    bool result = await Record().hasPermission();
    if (result) {
      Directory voiceMessageDirectory = await getApplicationDocumentsDirectory();
      consoleLog('Directory Path: ${voiceMessageDirectory.path}');
      voiceMessageFilePath = '';
      voiceMessageFilePath = '${voiceMessageDirectory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4';
      consoleLog('Audio Message Path: $voiceMessageFilePath');
      await Record()
          .start(
            path: voiceMessageFilePath,
            encoder: AudioEncoder.AAC,
            bitRate: 128000,
            samplingRate: 44100,
          )
          .then((value) => startTimer());
    } else {
      //get permission
    }
    isRecording = true;
    notifyListeners();
  }

  void stopRecording() async {
    isRecording = false;
    consoleLog('Audio Message Path: $voiceMessageFilePath');
    await Record().stop();
    voiceMessageFile = File(voiceMessageFilePath);
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
        duration: audioMessageDuration.inSeconds);

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
    waveFormTimer!.cancel();
  }

  void removeRecordedVoiceMessage() async {
    await Record().stop();
    voiceMessageFile = null;
    voiceMessageFilePath = '';
    notifyListeners();
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

  void addMessage([types.Message? message]) {
    messagesList.insert(0, message!);
    consoleLog('Message List Length : ${messagesList.length}');
    notifyListeners();
  }

  void addVoiceMessage() {
    addMessage(recordedVoiceMessage);

    voiceMessageFile = null;
    voiceMessageFilePath = '';
    notifyListeners();
  }

  ChatProvider.initialiseAndLoadMessages(this.selectedChatRoom) {
    notifyListeners();
  }

  void setAttachmentUploading(bool uploading) {
    isAttachmentUploading = uploading;
    notifyListeners();
  }

  void handleFBSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(message, selectedChatRoom);
  }

  void handleFBMessageTap(types.Message message) async {
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

  void handleFBPreviewDataFetched(types.TextMessage message, types.PreviewData previewData) {
    final updatedMessage = message.copyWith(previewData: previewData);
    FirebaseChatCore.instance.updateMessage(updatedMessage, selectedChatRoom!.id);
  }

  void handleFBImageSelection() async {
    final result = await ImagePicker().pickImage(imageQuality: 70, maxWidth: 1440, source: ImageSource.gallery);

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
            height: image.height.toDouble(), name: name, size: size, uri: uri, width: image.width.toDouble());

        FirebaseChatCore.instance.sendMessage(message, selectedChatRoom);
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

        FirebaseChatCore.instance.sendMessage(message, selectedChatRoom);
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
      consoleLog('Audio File : $name');
      final filePath = voiceMessageFile?.path;
      consoleLog('Audio File Path: $filePath');
      final file = File(filePath ?? '');
      consoleLog('Audio File Size: ${voiceMessageFile!.lengthSync()}');

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();
        consoleLog('Audio Url: $uri');
        consoleLog('Audio Type: ${lookupMimeType(filePath ?? '')}');

        final message = types.PartialVoice(
            mimeType: lookupMimeType(filePath ?? ''),
            name: name,
            size: voiceMessageFile!.lengthSync(),
            uri: uri,
            duration: audioMessageDuration.inSeconds);

        FirebaseChatCore.instance.sendMessage(message, selectedChatRoom);

        voiceMessageFile = null;
        voiceMessageFilePath = '';
        setAttachmentUploading(false);
      } on FirebaseException catch (e) {
        voiceMessageFile = null;
        voiceMessageFilePath = '';
        setAttachmentUploading(false);
        consoleLog(e.toString());
      }
    }
  }
}
