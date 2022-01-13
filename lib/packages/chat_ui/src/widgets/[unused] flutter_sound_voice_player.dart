// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
// import 'package:ttp_chat/utils/functions.dart';

// import 'inherited_chat_theme.dart';
// import 'inherited_l10n.dart';
// import 'inherited_user.dart';

// class VoiceMessage extends StatefulWidget {
//   /// Creates a voice message widget based on a [types.VoiceMessage]
//   const VoiceMessage({
//     Key? key,
//     required this.message,
//   }) : super(key: key);

//   /// [types.VoiceMessage]
//   final types.VoiceMessage? message;
//   @override
//   _VoiceMessageState createState() => _VoiceMessageState();
// }

// class _VoiceMessageState extends State<VoiceMessage> {
//   final FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();
//   bool _mPlayerIsInited = false;
//   StreamSubscription? _mPlayerSubscription;
//   int pos = 0;
//   int duration = 0;

//   @override
//   void initState() {
//     super.initState();
//     init().then((value) {
//       setState(() {
//         _mPlayerIsInited = true;
//       });
//     });
//     //! TODO : Bug : Duration remains same for every message if more than one voice message is sent
//     FlutterSoundHelper().duration(widget.message!.uri).then((value) {
//       consoleLog(widget.message!.uri);
//       consoleLog(value?.inMilliseconds.toString() ?? "NA");
//       setState(() {
//         duration = value?.inMilliseconds ?? 0;
//       });
//     });
//   }

//   //get duration text from milliseconds
//   String durationText(int milliseconds) {
//     int seconds = (milliseconds / 1000).truncate();
//     int minutes = (seconds / 60).truncate();
//     seconds = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   void dispose() {
//     stopPlayer(audioPlayer);
//     cancelPlayerSubscriptions();
//     // Be careful : you must `close` the audio session when you have finished with it.
//     audioPlayer.closeAudioSession();
//     super.dispose();
//   }

//   Future<void> init() async {
//     await audioPlayer.openAudioSession();
//     await audioPlayer.setSubscriptionDuration(const Duration(milliseconds: 50));

//     _mPlayerSubscription = audioPlayer.onProgress!.listen((e) {
//       consoleLog(e.toString());
//       duration = e.duration.inMilliseconds;
//       setPos(e.position.inMilliseconds);
//       setState(() {});
//     });
//   }

//   Future<void> setPos(int d) async {
//     if (d > duration) {
//       d = duration;
//     }
//     setState(() {
//       pos = d;
//     });
//   }

//   void cancelPlayerSubscriptions() {
//     if (_mPlayerSubscription != null) {
//       _mPlayerSubscription!.cancel();
//       _mPlayerSubscription = null;
//     }
//   }

//   // -------  Here is the code to playback  -----------------------

//   void play(FlutterSoundPlayer? player) async {
//     await player!.startPlayer(
//         fromURI: widget.message!.uri,
//         codec: Codec.aacADTS,
//         whenFinished: () {
//           setState(() {});
//         });
//     setState(() {});
//   }

//   void pause(FlutterSoundPlayer? player) async {
//     await player!.pausePlayer();
//     setState(() {});
//   }

//   void resume(FlutterSoundPlayer? player) async {
//     await player!.resumePlayer();
//     setState(() {});
//   }

//   Future<void> stopPlayer(FlutterSoundPlayer player) async {
//     await player.stopPlayer();
//     setState(() {});
//   }

//   getPlaybackFn(FlutterSoundPlayer player) {
//     if (!_mPlayerIsInited) {
//       return null;
//     }
//     return player.isPaused
//         ? resume(player)
//         : player.isStopped
//             ? play(player)
//             : player.isPlaying
//                 ? pause(player)
//                 : stopPlayer(player).then((value) => setState(() {}));
//   }

//   // --------------------------------------------------------------

//   @override
//   Widget build(BuildContext context) {
//     final _user = InheritedUser.of(context)!.user;

//     return Semantics(
//       key: widget.key,
//       label: InheritedL10n.of(context)!.l10n!.fileButtonAccessibilityLabel,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             GestureDetector(
//                 onTap: () => getPlaybackFn(audioPlayer),
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 14.0),
//                   child: audioPlayer.isPlaying
//                       ? const Icon(
//                           Icons.pause_rounded,
//                           color: Colors.white,
//                           size: 34,
//                         )
//                       : const Icon(
//                           Icons.play_arrow_rounded,
//                           color: Colors.white,
//                           size: 34,
//                         ),
//                 )),
//             Expanded(
//               child: LinearProgressIndicator(
//                 value: duration == 0 ? null : pos / duration,
//                 valueColor: const AlwaysStoppedAnimation(Colors.white),
//                 backgroundColor: Colors.grey[300],
//                 minHeight: 4.5,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(left: 24.0),
//               child: Text(
//                 durationText(audioPlayer.isPlaying ? pos : duration).toString(),
//                 style: _user?.id == widget.message?.author.id
//                     ? InheritedChatTheme.of(context)!.theme!.sentMessageBodyTextStyle
//                     : InheritedChatTheme.of(context)!.theme!.receivedMessageBodyTextStyle,
//                 textWidthBasis: TextWidthBasis.longestLine,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
