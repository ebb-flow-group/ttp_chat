import 'package:flutter/material.dart';

class Config {
  // Primary
  static const Color primaryColor = Color(0XFF003E52);
  static const Color midBlueColor = Color(0XFF83A7AF);
  static const Color lightBlueColor = Color.fromRGBO(230, 240, 243, 0.87);
  static const Color mentaikoColor = Color(0XFFFF5A5A);

  // Base
  static const Color creameryColor = Color(0XFFFDFBEF);
  static const Color creameryGlassColor = Color.fromRGBO(253, 251, 239, 0.65);
  static const Color darkCoverColor = Color.fromRGBO(25, 27, 30, 0.4);
  static const Color darkGlassColor = Color.fromRGBO(0, 62, 82, 0.7);

  // Neutrals
  static const Color blackColor = Color(0XFF191B1E);
  static const Color grayG1Color = Color(0XFF888888);
  static const Color grayG2Color = Color(0XFF999999);
  static const Color grayG3Color = Color(0XFFCBCBCB);
  static const Color grayG4Color = Color(0XFFE6E3DC);
  static const Color grayG5Color = Color(0XFFF2F2F2);
  static const Color grayG7Color = Color(0XFFF9F9F9);
  static const Color lightGrey = Color(0XFFE5E3DC);
  static const Color ivoryColor = Color(0XFFFCFCFE);

  // Accents
  static const Color deepLinkColor = Color(0XFFBB0974);
  static const Color linkColor = Color(0XFFDB0083);
  static const Color blueColor = Color(0XFF006EBE);

  // Alt
  static const Color deepTunaColor = Color(0XFFDF8877);
  static const Color midTunaColor = Color(0XFFF7D7C4);
  static const Color liteTunaColor = Color(0XFFF9F2EE);
  static const Color altBlueColor = Color(0XFF0D3B54);

  static const Color warning600Color = Color(0XFF775E0D);
  static const Color warning400Color = Color(0XFFE7B820);
  static const Color yellowColor = Color(0XFFFFCC32);
  static const Color warning200Color = Color(0XFFF3DB90);
  static const Color warning100Color = Color(0XFFF9EDC7);

  static const Color negative600Color = Color(0XFF8D0909);
  static const Color negative400Color = Color(0XFFE02B2B);
  static const Color negative200Color = Color(0XFFF99C9C);
  static const Color negative100Color = Color(0XFFFCCECE);

  static const Color positive600Color = Color(0XFF1A6234);
  static const Color positive400Color = Color(0XFF34C369);

  static const Color positive200Color = Color(0XFF97E3B3);
  static const Color positive100Color = Color(0XFFCBF1D9);
  static const Color successColor = Color(0XFF1BC4B0);

  static String kPlaceholderImg = 'https://i.ibb.co/d4XzKHD/Tabletop-Support-Profile-Icon.png';

  static const Gradient tabletopGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xff024B63),
      Color.fromRGBO(232, 58, 99, 0.9),
    ],
  );

  //Shared Preferences
  static const String activeBrandId = "active-brand-id";
}
