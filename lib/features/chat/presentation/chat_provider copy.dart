// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';

// import 'package:audioplayers/audioplayers.dart' as ap;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:get_it/get_it.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:mime/mime.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:record/record.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
// import 'package:uuid/uuid.dart';

// import '../../../models/base_model.dart';
// import '../../../network/api_service.dart';
// import '../../../packages/chat_core/ttp_chat_core.dart';
// import '../../../utils/functions.dart';
// import '../domain/brand_firebase_token_model.dart';
// import '../domain/chat_sign_in_model.dart';
// import '../domain/tabs_model.dart';
// import '../domain/user_firebase_token_model.dart';

// enum ApiStatus { called, success, failed }

// class ChatProvider extends ChangeNotifier {
//   types.User? user;
//   FlutterSoundRecorder flutterSoundRecorder = FlutterSoundRecorder();
//   FlutterSoundPlayer flutterSoundPlayer = FlutterSoundPlayer();
//   List<types.Message> messagesList = [];
//   Codec _codec = Codec.aacMP4;
//   String voiceMessageFilePath = '';
//   bool isRecording = false;
//   types.VoiceMessage? recordedVoiceMessage;
//   File? voiceMessageFile;
//   int? recordedVoiceMessageFileDuration;
//   Duration? audioMessageDuration;
//   Timer? audioMessageTimer;
//   bool isRecordedVoiceMessageFilePlaying = false;
//   ap.AudioPlayer? audioPlayer;
//   bool isAttachmentUploading = false;
//   List<double> waveFormList = [];
//   Timer? waveFormTimer;
//   ScrollController controller = ScrollController();
//   GlobalKey<AnimatedListState>? waveFormListKey;
//   ApiStatus apiStatus = ApiStatus.called;

//   // FB Integration Variables
//   types.Room? selectedChatUser;

//   // Chat Designs Start

//   // ChatUsersModel? usersModel;

//   bool? isSwitchedAccount;

//   List<TabsModel> tabs = [
//     TabsModel('All', true),
//     TabsModel('Chats', false),
//     TabsModel('Friends', false),
//     TabsModel('Merchants', false),
//   ];
//   TabsModel? selectedTab;

//   ChatProvider();

//   /// Not Needed Now
//   ChatProvider.signInAndInit(bool isSwitchedAccount) {
//     selectedTab = tabs[0];
//     isSwitchedAccount = isSwitchedAccount;
//     signInMVP();
//   }

//   /// Not Needed Now
//   ChatProvider.customSignIn(String customFirebaseToken, bool isSwitchedAccount) {
//     selectedTab = tabs[0];
//     isSwitchedAccount = isSwitchedAccount;
//     signInUserWithCustomFBTokenAndRegister(true, customFirebaseToken);
//   }

//   ///START
//   int selectedTabIndex = 0, brandListCount = 0, userListCount = 0;
//   bool isBrand = false, isLoading = false, isRoomListEmpty = false;
//   String? accessToken, refreshToken;

//   List<types.Room> roomList = [];
//   updateRoomList(List<types.Room> roomList) {
//     this.roomList = roomList;
//     // consoleLog(this.roomList.map((e) => e.name).toList().toString());
//     notifyListeners();
//   }

//   clearRoomList() {
//     SharedPreferences.getInstance().then((prefs) async {
//       await prefs.remove("roomList");
//     });
//   }

//   getLocalRoomList() {
//     SharedPreferences.getInstance().then((prefs) {
//       var data = prefs.getString("roomList");
//       if (data != null) {
//         List roomList = json.decode(data);
//         updateRoomList(
//           roomList.map((e) => types.Room.fromJson(e)).toList(),
//         );
//       }
//     });
//   }

//   saveRoomList(List<types.Room> roomList) {
//     SharedPreferences.getInstance().then((prefs) {
//       try {
//         List rooms = roomList.map((room) {
//           var createdAt = room.metadata?['last_messages']['createdAt'];
//           DateTime d = createdAt is Timestamp ? createdAt.toDate() : DateTime.now();
//           var formattedDate = DateFormat('hh:mm a').format(d);
//           room.metadata?['last_messages']["createdAt"] = formattedDate;
//           room.metadata?['last_messages']["updatedAt"] = formattedDate;
//           try {
//             json.encode(room.toJson());
//           } catch (e) {
//             room.metadata?['last_messages']["metadata"] = {};
//             try {
//               json.encode(room.toJson());
//             } catch (e) {
//               room.metadata?['last_messages'] = {};
//             }
//           }
//           return room.toJson();
//         }).toList();
//         // consoleLog(rooms.toString());
//         //consoleLog("Saved");
//         prefs.setString("roomList", json.encode(rooms));
//       } catch (e) {
//         consoleLog("Error");
//         consoleLog(e.toString());
//       }
//     });
//   }

//   ChatProvider.userSignIn(bool isSwitchedAccount, this.accessToken, this.refreshToken) {
//     selectedTab = tabs[0];
//     selectedTabIndex = 0;

//     if (FirebaseAuth.instance.currentUser == null) {
//       consoleLog('CURRENT USER IS NULL');
//       getUserFirebaseToken(accessToken!);
//     } else {
//       // FirebaseAuth.instance.currentUser!.reload();
//       getCountData();
//       apiStatus = ApiStatus.success;
//       notifyListeners();
//       consoleLog('CURRENT USER IS NOT NULL');
//     }
//   }

//   ChatProvider.brandSignIn(bool isSwitchedAccount, this.accessToken, this.refreshToken) {
//     selectedTabIndex = 0;

//     if (FirebaseAuth.instance.currentUser == null) {
//       getBrandFirebaseToken(accessToken!);
//       consoleLog('CURRENT BRAND IS NULL');
//     } else {
//       // FirebaseAuth.instance.currentUser!.reload();
//       getCountData();
//       apiStatus = ApiStatus.success;
//       notifyListeners();
//       consoleLog('CURRENT BRAND IS NOT NULL');
//     }
//   }

//   void userCustomFirebaseTokenSignIn(String firebaseToken) async {
//     consoleLog('USER FIREBASE TOKEN 1: $firebaseToken');
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
//       consoleLog('UserId: ${userCredential.user!.uid}');
//       checkIfUserIsBrandOrUser(userCredential.user!.uid);
//       getCountData();
//       // createUserOnFirestore(chatSignInModel, userCredential.user!.uid);
//       apiStatus = ApiStatus.success;
//       notifyListeners();
//     } catch (e, s) {
//       consoleLog('USER CUSTOM FIREBASE TOKEN SIGN IN ERROR: $e\n$s');
//     }
//   }

//   void brandCustomFirebaseTokenSignIn(List<BrandFirebaseTokenData> brandsList) async {
//     consoleLog('SECONDARY FB APP');
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(brandsList[0].firebaseToken!);
//       consoleLog('UserId: ${userCredential.user!.uid}');
//       checkIfUserIsBrandOrUser(userCredential.user!.uid);
//       getCountData();
//       // createBrandOnFirestore(selectedBrand, userCredential.user!.uid);
//       apiStatus = ApiStatus.success;
//       notifyListeners();
//     } catch (e, s) {
//       consoleLog('BRAND CUSTOM FIREBASE TOKEN SIGN IN ERROR: $e\n$s');
//     }
//   }

//   // void createUserOnFirestore(ChatSignInModel chatSignInModel, String uid) async {
//   //   try {
//   //     await FirebaseChatCore.instance.createUserInFirestore(
//   //       types.User(
//   //         firstName: chatSignInModel.userData != null ? chatSignInModel.userData!.firstName : 'Guest',
//   //         id: uid,
//   //         imageUrl: 'https://i.pravatar.cc/300?u=Shubham',
//   //         lastName: chatSignInModel.userData != null ? chatSignInModel.userData!.lastName : '',
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     consoleLog('USER SIGN UP ERROR: $e');
//   //   }
//   // }

//   // void createBrandOnFirestore(BrandChatFirebaseTokenResponse selectedBrand, String uid) async {
//   //   try {
//   //     await FirebaseChatCore.instance.createUserInFirestore(
//   //       types.User(
//   //         firstName: selectedBrand.brandName,
//   //         id: uid,
//   //         imageUrl: 'https://i.pravatar.cc/300?u=Shubham',
//   //         lastName: '',
//   //       ),
//   //     );
//   //   } catch (e) {
//   //     consoleLog('BRAND SIGN UP ERROR: $e');
//   //   }
//   // }

//   void updateTabIndex(int value) {
//     selectedTabIndex = value;
//     notifyListeners();
//   }

//   void checkIfUserIsBrandOrUser(String uid) async {
//     final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();

//     final data = snapshot.data();
//     consoleLog('USER TYPE: ${data!['user_type']}');
//     if (data['user_type'] == 'brand') {
//       isBrand = true;
//     } else if (data['user_type'] == 'user') {
//       isBrand = false;
//     }
//     notifyListeners();
//   }

//   void getUserFirebaseToken(String accessToken) async {
//     consoleLog('ACCESS TOKEN 1: $accessToken');
//     BaseModel<UserFirebaseTokenModel> response = await GetIt.I<ApiService>().getUserFirebaseToken(accessToken);

//     if (response.data != null) {
//       consoleLog('USER FIREBASE TOKEN 1: ${response.data!.firebaseToken!}');
//       userCustomFirebaseTokenSignIn(response.data!.firebaseToken!);
//     } else {
//       apiStatus = ApiStatus.failed;
//       notifyListeners();

//       consoleLog('CUSTOM SIGN IN ERROR: ${response.getException.getErrorMessage()}');
//     }
//   }

//   void getBrandFirebaseToken(String accessToken) async {
//     consoleLog('ACCESS TOKEN 1: $accessToken');
//     BaseModel<BrandFirebaseTokenModel> response = await GetIt.I<ApiService>().getBrandFirebaseToken(accessToken);

//     if (response.data != null) {
//       consoleLog('BRAND FIREBASE TOKEN 1: ${response.data!.toJson()}');

//       if (response.data!.brandFirebaseTokenList!.isEmpty || response.data!.brandFirebaseTokenList!.length > 1) {
//         apiStatus = ApiStatus.failed;
//         notifyListeners();
//       } else {
//         brandCustomFirebaseTokenSignIn(response.data!.brandFirebaseTokenList!);
//       }
//     } else {
//       apiStatus = ApiStatus.failed;
//       notifyListeners();

//       consoleLog('CUSTOM SIGN IN ERROR: ${response.getException.getErrorMessage()}');
//     }
//   }

//   void getCountData() {
//     isLoading = true;
//     notifyListeners();
//     FirebaseChatCore.instance.rooms().listen((event) {
//       isLoading = false;
//       notifyListeners();
//       if (event.isEmpty) {
//         isRoomListEmpty = true;
//         notifyListeners();
//       } else {
//         brandListCount = event.where((element) => element.metadata!['other_user_type'] == 'brand').toList().length;
//         userListCount = event.where((element) => element.metadata!['other_user_type'] == 'user').toList().length;
//         notifyListeners();
//       }
//     });
//   }

//   /// END

//   // customTokenFirebaseAuthSignIn(bool isSwitchedAccount, String firebaseToken) async {
//   //   try {
//   //     if (isSwitchedAccount) {
//   //       consoleLog('SECONDARY FB APP');

//   //       FirebaseApp secondaryApp = Firebase.app('secondary');

//   //       UserCredential userCredential =
//   //           await FirebaseAuth.instanceFor(app: secondaryApp).signInWithCustomToken(firebaseToken);
//   //       consoleLog('USER CREDENTIAL: ${await userCredential.user!.getIdToken()}');
//   //       consoleLog('USER CREDENTIAL: $firebaseToken');
//   //       registerUserOnFirestore(userCredential.user!.uid, isSwitchedAccount);
//   //     } else {
//   //       consoleLog('PRIMARY FB APP');
//   //       if (chatSignInModel != null) {
//   //         UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
//   //         consoleLog('USER CREDENTIAL: ${await userCredential.user!.getIdToken()}');
//   //         consoleLog('USER CREDENTIAL: $firebaseToken');
//   //         registerUserOnFirestore(userCredential.user!.uid, isSwitchedAccount);
//   //       }
//   //     }
//   //     apiStatus = ApiStatus.success;
//   //     notifyListeners();
//   //   } catch (e, s) {
//   //     consoleLog('CUSTOM SIGN IN ERROR: $e\n$s');
//   //   }
//   // }

//   void registerUserOnFirestore(String uid, bool isSwitchedAccount) async {
//     consoleLog('INSIDE REGISTER');
//     consoleLog('UID: $uid');

//     try {
//       await FirebaseChatCore.instance.createUserInFirestore(
//         types.User(
//           firstName: 'Shubham',
//           id: uid,
//           imageUrl: 'https://i.pravatar.cc/300?u=Shubham',
//           lastName: isSwitchedAccount ? 'Bichkar Brand' : 'Bichkar',
//         ),
//       );
//       /*Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => ChatScreen(widget.chatUsersModel),
//           ));*/

//     } catch (e) {
//       consoleLog('CUSTOM SIGN UP ERROR: $e');
//     }
//   }

//   /// Not Needed Now

//   /// Not Needed Now
//   // void signInMVP() async {
//   //   BaseModel<ChatSignInModel> response = await GetIt.I<ApiService>().signInMVP('shubham_8607', '8668292003');

//   //   if (response.data != null) {
//   //     apiStatus = ApiStatus.success;
//   //     notifyListeners();

//   //     chatSignInModel = response.data;
//   //     notifyListeners();
//   //     signInUserWithCustomFBTokenAndRegister(false, response.data!.firebaseToken!, response.data!);

//   //     /*Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //             builder: (context) => UserAccounts(response.data.brand_custom_firebase_tokens)));*/
//   //   } else {
//   //     apiStatus = ApiStatus.failed;
//   //     notifyListeners();
//   //     /*showMessage(
//   //       context,
//   //       "Error",
//   //       response.getException.getErrorMessage(),
//   //     );*/
//   //     consoleLog('CUSTOM SIGN IN ERROR: ${response.getException.getErrorMessage()}');
//   //   }
//   // }

//   /// Not Needed Now
//   void initializeUser() {
//     user = const types.User(id: '06c33e8b-e835-4736-80f4-63f44b66666c');
//     notifyListeners();
//   }

//   /// Not Needed Now
//   void loadMessages() async {
//     final response = await rootBundle.loadString('assets/messages.json');
//     final messages =
//         (jsonDecode(response) as List).map((e) => types.Message.fromJson(e as Map<String, dynamic>)).toList();

//     messagesList = messages;
//     notifyListeners();
//   }

//   void startRecording() async {
//     bool result = await Record().hasPermission();

//     if (result) {
//       Directory voiceMessageDirectory = await getApplicationDocumentsDirectory();

//       consoleLog('APP APPLE DOCS DIRE: ${voiceMessageDirectory.path}');

//       voiceMessageFilePath = '';
//       voiceMessageFilePath = '${voiceMessageDirectory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.mp4';

//       consoleLog('APP APPLE DOCS DIRE: $voiceMessageFilePath');

//       await Record().start(
//         path: voiceMessageFilePath,
//         encoder: AudioEncoder.AAC,
//         bitRate: 128000,
//         samplingRate: 44100,
//       );
//     } else {
//       //get permission
//     }

//     isRecording = true;

//     /*_mPath = DateTime.now().millisecondsSinceEpoch.toString();
//     _mPathMp3 = DateTime.now().millisecondsSinceEpoch.toString();

//     flutterSoundRecorder.startRecorder(
//       toFile: _mPath,
//       codec: _codec,
//     );*/
//     notifyListeners();
//   }

//   void stopRecording() async {
//     isRecording = false;
//     consoleLog('VOICE MESSAGE FILE PATH: $voiceMessageFilePath');
//     await Record().stop();

//     voiceMessageFile = File(voiceMessageFilePath);
//     audioMessageDuration = await FlutterSoundHelper().duration(voiceMessageFilePath);

//     consoleLog('DURATION FOR METADATA: ${audioMessageDuration!.inSeconds}');

//     recordedVoiceMessageFileDuration = audioMessageDuration!.inSeconds;

//     recordedVoiceMessage = null;

//     recordedVoiceMessage = types.VoiceMessage(
//         author: user ??
//             types.User(
//               id: FirebaseAuth.instance.currentUser!.uid,
//             ),
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         id: const Uuid().v4(),
//         mimeType: lookupMimeType(voiceMessageFilePath),
//         name: voiceMessageFilePath.split('/').last,
//         size: File(voiceMessageFilePath).lengthSync(),
//         uri: voiceMessageFilePath,
//         duration: Duration.zero.inSeconds);

//     consoleLog('METADATA: ${recordedVoiceMessage!.metadata}');

//     handleSendVoiceMessagePressed();

//     notifyListeners();

//     // addMessage(message);

//     /*flutterSoundRecorder.stopRecorder();

//     if(_mPath.isNotEmpty && _mPath != null)
//     {
//       bool isConverted = await FlutterSoundHelper().convertFile(_mPath, Codec.aacMP4, DateTime.now().millisecondsSinceEpoch.toString(), Codec.mp3);

//       if(isConverted) {
//         consoleLog('MP3 File PATH: $_mPathMp3');

//         if (_mPathMp3 != null) {

//           Directory voiceMessageDir = await getTemporaryDirectory();
//           String mp3FilePath = '${voiceMessageDir.path}/$_mPathMp3.mp3';
//           File mp3File = File(mp3FilePath);
//           consoleLog('FILE PATH: $mp3FilePath');
//           consoleLog('FILE: $mp3File');
//           consoleLog('FILE: ${lookupMimeType(mp3FilePath ?? '')}');

//           final message = types.VoiceMessage(
//             author: user,
//             createdAt: DateTime.now().millisecondsSinceEpoch,
//             id: Uuid().v4(),
//             mimeType: lookupMimeType(mp3FilePath ?? ''),
//             name: mp3FilePath.split('/').last,
//             size: 59675,
//             uri: 'http://mirrors.standaloneinstaller.com/audio-sample/aac/in.aac' ?? '',
//           );

//           addMessage(message);
//         }
//       }
//     }*/
//   }

//   void startWaveFormAnimation() {
//     /*if(isRecording)
//       {
//         const oneSec = Duration(milliseconds: 200);
//         waveFormTimer = Timer.periodic(oneSec, (Timer t) => consoleLog('hi!'));
//       }*/

//     waveFormListKey = GlobalKey();

//     const oneSec = Duration(milliseconds: 400);
//     waveFormList.clear();
//     waveFormTimer = Timer.periodic(oneSec, (Timer t) {
//       waveFormList.add(Random().nextInt(46).toDouble());
//       waveFormListKey!.currentState?.insertItem(waveFormList.length - 1);
//       controller.animateTo(controller.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//       notifyListeners();
//     });
//     notifyListeners();
//   }

//   void stopWaveFormAnimation() {
//     // if(waveFormListKey.currentState.mounted) waveFormListKey.currentState.dispose();
//     waveFormTimer!.cancel();
//   }

//   void startAudioMessageTimer() {
//     const oneSec = Duration(seconds: 1);
//     audioMessageTimer = Timer.periodic(
//       oneSec,
//       (Timer timer) {
//         if (recordedVoiceMessageFileDuration == 0) {
//           timer.cancel();
//           recordedVoiceMessageFileDuration = audioMessageDuration!.inSeconds;
//           notifyListeners();
//         } else {
//           if (recordedVoiceMessageFileDuration != null) {
//             recordedVoiceMessageFileDuration = recordedVoiceMessageFileDuration! - 1;
//           }
//           notifyListeners();
//         }
//       },
//     );
//   }

//   void disposeAudioMessageTimer() {
//     if (audioMessageTimer != null) audioMessageTimer!.cancel();
//   }

//   void playVoiceMessageAnimation() {
//     plays(voiceMessageFilePath);
//     isRecordedVoiceMessageFilePlaying = true;
//     notifyListeners();
//   }

//   void stopVoiceMessageAnimation() {
//     removeRecordedVoiceMessage();
//   }

//   void removeRecordedVoiceMessage() async {
//     await Record().stop();
//     voiceMessageFile = null;
//     voiceMessageFilePath = '';
//     isRecordedVoiceMessageFilePlaying = false;
//     // audioPlayer.stop();
//     // audioPlayer.dispose();
//     notifyListeners();
//   }

//   void openTheRecorder() async {
//     if (!kIsWeb) {
//       var status = await Permission.microphone.request();
//       if (status != PermissionStatus.granted) {
//         throw RecordingPermissionException('Microphone permission not granted');
//       }

//       var storageStatus = await Permission.storage.request();
//       if (storageStatus != PermissionStatus.granted) {
//         throw Exception('Storage permission not granted');
//       }
//     }
//     await flutterSoundRecorder.openAudioSession();
//     if (!await flutterSoundRecorder.isEncoderSupported(_codec) && kIsWeb) {
//       _codec = Codec.aacMP4;
//       //  _mPath = DateTime.now().millisecondsSinceEpoch.toString();
//       if (!await flutterSoundRecorder.isEncoderSupported(_codec) && kIsWeb) {
//         return;
//       }
//     }
//   }

//   void handleImageSelection() async {
//     final result = await ImagePicker().pickImage(
//       imageQuality: 70,
//       maxWidth: 1440,
//       source: ImageSource.gallery,
//     );

//     if (result != null) {
//       final bytes = await result.readAsBytes();
//       final image = await decodeImageFromList(bytes);

//       final message = types.ImageMessage(
//         author: user!,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         height: image.height.toDouble(),
//         id: const Uuid().v4(),
//         name: result.path.split('/').last,
//         size: bytes.length,
//         uri: result.path,
//         width: image.width.toDouble(),
//       );

//       addMessage(message);
//     }
//   }

//   void handleFileSelection() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//     );

//     if (result != null) {
//       final message = types.FileMessage(
//         author: user!,
//         createdAt: DateTime.now().millisecondsSinceEpoch,
//         id: const Uuid().v4(),
//         mimeType: lookupMimeType(result.files.single.path ?? ''),
//         name: result.files.single.name,
//         size: result.files.single.size,
//         uri: result.files.single.path ?? '',
//       );

//       addMessage(message);
//     }
//   }

//   void handleVoiceMessageSelection(BuildContext context) async {
//     showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
//             return Dialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//               //this right here
//               child: SizedBox(
//                 height: 300.0,
//                 width: 300.0,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: <Widget>[
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.all(15.0),
//                       child: Text(
//                         'Press and hold button to record your message.',
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     Expanded(
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                               width: 100.0,
//                               height: 100.0,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                                 border: Border.all(color: Theme.of(context).colorScheme.secondary),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.grey[200]!,
//                                     spreadRadius: 1,
//                                     blurRadius: 7,
//                                     offset: const Offset(0, 0), // changes position of shadow
//                                   ),
//                                 ],
//                               ),
//                               child: GestureDetector(
//                                 onTapDown: (TapDownDetails tapDownDetails) {
//                                   setState(() {
//                                     isRecording = true;
//                                   });
//                                   startRecording();
//                                 },
//                                 onTapUp: (TapUpDetails tapUpDetails) {
//                                   setState(() {
//                                     isRecording = false;
//                                   });
//                                   stopRecording();
//                                   Navigator.pop(context);
//                                 },
//                                 onTapCancel: () {
//                                   setState(() {
//                                     isRecording = false;
//                                   });
//                                   stopRecording();
//                                   Navigator.pop(context);
//                                 },
//                                 child: Icon(Icons.multitrack_audio,
//                                     size: 60.0, color: Theme.of(context).colorScheme.secondary),
//                               )),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           });
//         });
//   }

//   void handleMessageTap(types.Message message) async {
//     consoleLog('MESSAGE TYPE: ${message.type}');
//     if (message is types.FileMessage) {
//       await OpenFile.open(message.uri);
//       // notifyListeners();
//     }
//   }

//   // void handleSendPressed(types.PartialText message) {
//   //   final textMessage = types.TextMessage(
//   //     author: user!,
//   //     createdAt: DateTime.now().millisecondsSinceEpoch,
//   //     id: const Uuid().v4(),
//   //     text: message.text,
//   //   );

//   //   addMessage(textMessage);
//   // }

//   void addMessage([types.Message? message]) {
//     messagesList.insert(0, message!);
//     consoleLog('MESSAGE LIST LENGTH: ${messagesList.length}');
//     notifyListeners();
//   }

//   // void addVoiceMessage() {
//   //   addMessage(recordedVoiceMessage);
//   //   isRecordedVoiceMessageFilePlaying = false;
//   //   voiceMessageFile = null;
//   //   voiceMessageFilePath = '';
//   //   notifyListeners();
//   // }

//   void plays(String uri) async {
//     // if (audioPlayer != null) audioPlayer.dispose();
//     audioPlayer = ap.AudioPlayer(playerId: voiceMessageFilePath.split('/').last);
//     audioPlayer!.onPlayerStateChanged.listen((s) {
//       if (s == ap.PlayerState.PLAYING) {
//         consoleLog('Playing');
//       } else if (s == ap.PlayerState.PAUSED) {
//         consoleLog('Paused');
//       } else if (s == ap.PlayerState.COMPLETED) {
//         consoleLog('Completed');
//         // onComplete();

//         audioPlayer!.dispose();
//         isRecordedVoiceMessageFilePlaying = false;
//         notifyListeners();
//       }
//     }, onError: (msg) {
//       consoleLog('Error: $msg');
//       // onStop();

//       audioPlayer!.dispose();
//       isRecordedVoiceMessageFilePlaying = false;
//       notifyListeners();
//     });

//     await audioPlayer!.play(uri, isLocal: true);
//     startAudioMessageTimer();
//   }

//   /*void onComplete() {
//     audioPlayer.stop();
//     audioPlayer = null;
//     isRecordedVoiceMessageFilePlaying = false;
//     notifyListeners();
//   }

//   void onStop() {
//     audioPlayer.stop();
//     audioPlayer = null;
//     isRecordedVoiceMessageFilePlaying = false;
//     notifyListeners();
//   }*/

//   ChatProvider.initialiseAndLoadMessages(this.selectedChatUser, this.isSwitchedAccount) {
//     notifyListeners();
//   }

//   void updateSwitchedAccountValue(bool value) {}

//   void setAttachmentUploading(bool uploading) {
//     isAttachmentUploading = uploading;
//     notifyListeners();
//   }

//   // void signInUserWithCustomFBTokenAndRegister(bool isSwitchedAccount,
//   //     [String? customFirebaseToken, ChatSignInModel? chatSignInModel]) async {
//   //   try {
//   //     if (isSwitchedAccount) {
//   //       consoleLog('SECONDARY FB APP');
//   //       FirebaseApp secondaryApp = Firebase.app('secondary');
//   //       UserCredential userCredential =
//   //           await FirebaseAuth.instanceFor(app: secondaryApp).signInWithCustomToken(customFirebaseToken!);
//   //       consoleLog('USER CREDENTIAL: ${await userCredential.user!.getIdToken()}');
//   //       consoleLog('USER CREDENTIAL: $customFirebaseToken');
//   //       registerUserOnFirestore(userCredential.user!.uid, isSwitchedAccount);
//   //     } else {
//   //       consoleLog('PRIMARY FB APP');
//   //       if (chatSignInModel != null) this.chatSignInModel = chatSignInModel;
//   //       notifyListeners();
//   //       UserCredential userCredential = await FirebaseAuth.instance.signInWithCustomToken(customFirebaseToken!);
//   //       consoleLog('USER CREDENTIAL: ${await userCredential.user!.getIdToken()}');
//   //       consoleLog('USER CREDENTIAL: $customFirebaseToken');
//   //       registerUserOnFirestore(userCredential.user!.uid, isSwitchedAccount);
//   //     }

//   //     /*if(chatSignInModel != null) this.chatSignInModel = chatSignInModel;
//   //     notifyListeners();
//   //     UserCredential userCredential = await FirebaseAuth.instance
//   //         .signInWithCustomToken(customFirebaseToken);
//   //     consoleLog('USER CREDENTIAL: ${await userCredential.user.getIdToken()}');
//   //     consoleLog('USER CREDENTIAL: $customFirebaseToken');
//   //     registerUserOnFirestore(userCredential.user.uid);*/

//   //   } catch (e) {
//   //     consoleLog('CUSTOM SIGN IN ERROR: $e');
//   //   }
//   // }

//   // void handleFBSendPressed(types.PartialText message) {
//   //   /*isSwitchedAccount!
//   //       ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).sendMessage(
//   //           message,
//   //           selectedChatUser!.id,
//   //         )
//   //       : */
//   //   FirebaseChatCore.instance.sendMessage(
//   //     message,
//   //     selectedChatUser!.id,
//   //   );
//   // }

//   void handleFBMessageTap(types.Message message) async {
//     if (message is types.FileMessage) {
//       var localPath = message.uri;

//       consoleLog('LOCAL PATH: $localPath');

//       if (message.uri.startsWith('https')) {
//         final client = http.Client();
//         final request = await client.get(Uri.parse(message.uri));
//         final bytes = request.bodyBytes;
//         final documentsDir = (await getExternalStorageDirectory())!.path;
//         localPath = '$documentsDir/${message.name}';

//         if (!File(localPath).existsSync()) {
//           final file = File(localPath);
//           await file.writeAsBytes(bytes);
//         }
//       }

//       await OpenFile.open(localPath);
//     } else if (message is types.VoiceMessage) {
//       Duration? duration = await FlutterSoundHelper().duration(message.uri);
//       consoleLog('ON TAP DURATION: $duration');
//     }
//   }

//   void handleFBPreviewDataFetched(types.TextMessage message, types.PreviewData previewData) {
//     final updatedMessage = message.copyWith(previewData: previewData);

//     /*isSwitchedAccount!
//         ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).updateMessage(updatedMessage, selectedChatUser!.id)
//         : */
//     FirebaseChatCore.instance.updateMessage(updatedMessage, selectedChatUser!.id);
//   }

//   void handleFBImageSelection() async {
//     final result = await ImagePicker().pickImage(
//       imageQuality: 70,
//       maxWidth: 1440,
//       source: ImageSource.gallery,
//     );

//     if (result != null) {
//       setAttachmentUploading(true);
//       final file = File(result.path);
//       final size = file.lengthSync();
//       final bytes = await result.readAsBytes();
//       final image = await decodeImageFromList(bytes);
//       final name = result.path.split('/').last;

//       try {
//         final reference =
//             /*isSwitchedAccount!
//             ? FirebaseStorage.instanceFor(app: Firebase.app('secondary')).ref(name)
//             : */
//             FirebaseStorage.instance.ref(name);
//         await reference.putFile(file);
//         final uri = await reference.getDownloadURL();

//         final message = types.PartialImage(
//           height: image.height.toDouble(),
//           name: name,
//           size: size,
//           uri: uri,
//           width: image.width.toDouble(),
//         );

//         /*isSwitchedAccount!
//             ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).sendMessage(message, selectedChatUser!.id)
//             : */
//         FirebaseChatCore.instance.sendMessage(
//           message,
//           selectedChatUser!.id,
//         );
//         setAttachmentUploading(false);
//       } on FirebaseException catch (e) {
//         setAttachmentUploading(false);
//         consoleLog(e.toString());
//       }
//     }
//   }

//   void handleFBFileSelection() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.any,
//     );

//     if (result != null) {
//       setAttachmentUploading(true);
//       final name = result.files.single.name;
//       final filePath = result.files.single.path;
//       final file = File(filePath ?? '');

//       try {
//         final reference =
//             /*isSwitchedAccount!
//             ? FirebaseStorage.instanceFor(app: Firebase.app('secondary')).ref(name)
//             : */
//             FirebaseStorage.instance.ref(name);
//         await reference.putFile(file);
//         final uri = await reference.getDownloadURL();

//         final message = types.PartialFile(
//           mimeType: lookupMimeType(filePath ?? ''),
//           name: name,
//           size: result.files.single.size,
//           uri: uri,
//         );

//         /*isSwitchedAccount!
//             ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).sendMessage(message, selectedChatUser!.id)
//             : */
//         FirebaseChatCore.instance.sendMessage(message, selectedChatUser!.id);
//         setAttachmentUploading(false);
//       } on FirebaseException catch (e) {
//         setAttachmentUploading(false);
//         consoleLog(e.toString());
//       }
//     }
//   }

//   void handleSendVoiceMessagePressed() async {
//     if (voiceMessageFile != null) {
//       setAttachmentUploading(true);
//       final name = voiceMessageFile!.path.split('/').last;
//       consoleLog('VOICE MESSAGE FILE NAME: $name');
//       final filePath = voiceMessageFile?.path;
//       consoleLog('VOICE MESSAGE FILE PATH: $filePath');
//       final file = File(filePath ?? '');
//       consoleLog('VOICE MESSAGE FILE: $file');
//       consoleLog('VOICE MESSAGE FILE SIZE: ${voiceMessageFile!.lengthSync()}');

//       try {
//         final reference = /*isSwitchedAccount!
//           ? FirebaseStorage.instanceFor(app: Firebase.app('secondary')).ref(name)
//           : */
//             FirebaseStorage.instance.ref(name);
//         await reference.putFile(file);
//         final uri = await reference.getDownloadURL();
//         consoleLog('VOICE MESSAGE FILE FB STORAGE URL: $uri');
//         consoleLog('VOICE MESSAGE FILE MIME TYPE: ${lookupMimeType(filePath ?? '')}');

//         final message = types.PartialVoice(
//             mimeType: lookupMimeType(filePath ?? ''),
//             name: name,
//             size: voiceMessageFile!.lengthSync(),
//             uri: uri,
//             duration: audioMessageDuration!.inSeconds);

//         /*isSwitchedAccount!
//               ? FirebaseChatCore.instanceFor(app: Firebase.app('secondary')).sendMessage(message, selectedChatUser!.id)
//               : */
//         FirebaseChatCore.instance.sendMessage(message, selectedChatUser!.id);
//         isRecordedVoiceMessageFilePlaying = false;
//         voiceMessageFile = null;
//         voiceMessageFilePath = '';
//         setAttachmentUploading(false);
//       } on FirebaseException catch (e) {
//         isRecordedVoiceMessageFilePlaying = false;
//         voiceMessageFile = null;
//         voiceMessageFilePath = '';
//         setAttachmentUploading(false);
//         consoleLog(e.toString());
//       }
//     }
//   }
// }
