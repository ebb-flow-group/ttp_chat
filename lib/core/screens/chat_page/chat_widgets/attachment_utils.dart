import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ttp_chat/features/chat/presentation/chat_provider.dart';

import 'bottomsheet_item.dart';

handleAttachmentPressed(BuildContext context, {required ChatProvider chatProvider}) {
  FocusScope.of(context).requestFocus(FocusNode());
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.grey.withOpacity(.75),
    elevation: 20,
    builder: (BuildContext context) {
      return Wrap(children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
              ),
              const SizedBox(
                height: 20,
              ),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  BottomSheetItem(
                      leading: SvgPicture.asset('assets/icons/photo.svg',
                          height: 18, width: 18, color: Theme.of(context).primaryColor),
                      title: const Text('Upload a photo'),
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.handleFBImageSelection();
                      }),
                  /*_ListItem(
                      leading: SvgPicture.asset(
                        'assets/icon/file.svg',
                        height: 18,
                        width: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text('Upload a file'),
                      onTap: () {
                        Navigator.pop(context);
                        chatProvider.handleFBFileSelection();
                      },
                    ),*/
                  // Divider(),
                  const SizedBox(height: 50),
                ],
              ),
            ],
          ),
        ),
      ]);
    },
  );
}
