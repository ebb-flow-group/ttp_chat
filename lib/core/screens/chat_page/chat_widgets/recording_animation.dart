import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';

class RecordingAnimation extends StatelessWidget {
  const RecordingAnimation({
    Key? key,
    required this.offset,
    required this.chatProvider,
    required this.controller,
  }) : super(key: key);

  final Animation<Offset> offset;
  final ChatProvider chatProvider;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 88,
          padding: EdgeInsets.only(
              top: 20, bottom: 20 + MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 1),
                color: const Color(0xFF000000).withOpacity(.15),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icon/delete.svg',
                  package: 'ttp_chat',
                  color: Colors.white,
                  width: 18,
                  height: 18,
                ),
                onPressed: () {
                  chatProvider.stopWaveFormAnimation();
                  controller.reverse();
                  chatProvider.removeRecordedVoiceMessage();
                },
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: chatProvider.controller,
                    child: AnimatedList(
                      key: chatProvider.waveFormListKey,
                      initialItemCount: chatProvider.waveFormList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (context, index, animation) {
                        return SlideTransition(
                          position: CurvedAnimation(
                            curve: Curves.easeOut,
                            parent: animation,
                          ).drive((Tween<Offset>(
                            begin: const Offset(-1, 0),
                            end: const Offset(0, 0),
                          ))),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: Container(
                                  width: 3,
                                  height:
                                      chatProvider.waveFormList[index] == 0.0 || chatProvider.waveFormList[index] == 1.0
                                          ? 2.0
                                          : chatProvider.waveFormList[index],
                                  decoration:
                                      BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icon/send.svg',
                  package: 'ttp_chat',
                  color: Colors.white,
                  width: 18,
                  height: 18,
                ),
                onPressed: () {
                  chatProvider.stopRecording();
                  controller.reverse();
                  chatProvider.stopWaveFormAnimation();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
