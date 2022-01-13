import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:ttp_chat/packages/chat_types/ttp_chat_types.dart' as types;
import 'package:ttp_chat/utils/functions.dart';

import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'inherited_user.dart';

class VoiceMessage extends StatefulWidget {
  /// Creates a voice message widget based on a [types.VoiceMessage]
  const VoiceMessage({Key? key, required this.message}) : super(key: key);

  /// [types.VoiceMessage]
  final types.VoiceMessage? message;

  @override
  _VoiceMessageState createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  AudioPlayer? audioPlayer;
  Duration? duration;
  Duration? position;

  PlayerState playerState = PlayerState.STOPPED;

  get durationText => duration != null ? duration.toString().split('.').first : '';

  get positionText => position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  List<String> urlList = [];
  String firstUrl = '';
  Timer? timer;
  Duration interval = const Duration(seconds: 1);
  int globalTimerMaxSeconds = 0, currentSeconds = 0, timerMaxSeconds = 0;
  String get getterTimerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}:${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  String timerText = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      globalTimerMaxSeconds = widget.message!.duration;
      timerMaxSeconds = widget.message!.duration;
      timerText = '${timerMaxSeconds}s';
    });
  }

  void startTimeout([int? milliseconds]) {
    final duration = interval;
    Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          this.timer = timer;
          currentSeconds = timer.tick;
          timerText = getterTimerText;
          if (timer.tick >= timerMaxSeconds) {
            timer.cancel();
            timerMaxSeconds = globalTimerMaxSeconds;
            timerText = '${globalTimerMaxSeconds}s';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    if (audioPlayer != null) audioPlayer!.dispose();
    super.dispose();
  }

  void onComplete() {
    audioPlayer!.stop();
    setState(() {
      playerState = PlayerState.COMPLETED;
      if (Platform.isAndroid) {
        duration = const Duration(seconds: 0);
        position = const Duration(seconds: 0);
      }
    });
  }

  void play() async {
    audioPlayer = AudioPlayer(playerId: widget.message!.uri.split('/').last);
    audioPlayer!.onAudioPositionChanged.listen((p) => setState(() => position = p));
    audioPlayer!.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.PLAYING) {
        audioPlayer!.onDurationChanged.listen((Duration d) {
          consoleLog('Max duration: $d');
          setState(() => duration = d);
        });
        setState(() {
          playerState = PlayerState.PLAYING;
          consoleLog('Playing');
          Future.delayed(const Duration(seconds: 1), () => startTimeout());
        });
      } else if (s == PlayerState.PAUSED) {
        setState(() {
          playerState = PlayerState.PAUSED;
          consoleLog('Paused');
        });
      } else if (s == PlayerState.COMPLETED) {
        setState(() {
          playerState = PlayerState.COMPLETED;
          consoleLog('Completed');
        });
        onComplete();
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.COMPLETED;
      });
      consoleLog('Error: $msg');
    });

    await audioPlayer!.play(widget.message!.uri, isLocal: false);
  }

  Future stop() async {
    await audioPlayer!.stop();
    setState(() {
      playerState = PlayerState.PAUSED;
      playerState = PlayerState.STOPPED;
      duration = const Duration(seconds: 0);
      position = const Duration(seconds: 0);
    });
  }

  Future pause() async {
    await audioPlayer!.pause();
    setState(() {
      playerState = PlayerState.PAUSED;
      timer!.cancel();
      timerMaxSeconds = timerMaxSeconds - currentSeconds;
    });
  }

  Future resume() async {
    await audioPlayer!.resume();
    setState(() {
      playerState = PlayerState.PLAYING;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context)!.user;

    return Semantics(
      key: widget.key,
      label: InheritedL10n.of(context)!.l10n!.fileButtonAccessibilityLabel,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 24, 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
                onTap: () {
                  if (playerState == PlayerState.PLAYING) {
                    pause();
                  } else if (playerState == PlayerState.PAUSED) {
                    resume();
                  } else {
                    consoleLog('PLAYED AUDIO PATH: ${widget.message!.uri}');
                    play();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: playerState == PlayerState.PLAYING
                      ? const Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                          size: 34,
                        )
                      : const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                )),
            Expanded(
              child: LinearProgressIndicator(
                value: position != null && position!.inSeconds > 0 && duration != null && duration!.inSeconds > 0
                    ? (position?.inSeconds.toDouble() ?? 0.0) / (duration?.inSeconds.toDouble() ?? 0.0)
                    : 0.0,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                backgroundColor: Colors.grey[300],
                minHeight: 4.5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: Text(
                timerText,
                style: _user?.id == widget.message?.author.id
                    ? InheritedChatTheme.of(context)!.theme!.sentMessageBodyTextStyle
                    : InheritedChatTheme.of(context)!.theme!.receivedMessageBodyTextStyle,
                textWidthBasis: TextWidthBasis.longestLine,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
