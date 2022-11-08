import 'package:flutter/material.dart';

class ThemeUtils {
  static final ThemeData defaultAppThemeData = appTheme();

  static ThemeData appTheme() {
    return ThemeData(
      fontFamily: 'AvertaStd',
      primaryColor: const Color(0xFF234958),
      hintColor: const Color(0xFF999999),
      dividerColor: const Color(0xFFE5E3DC),
      highlightColor: const Color(0xFFE28777),
      disabledColor: const Color(0xFFE5E3DC),
      errorColor: const Color(0xFFFF5A5A),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFF234958),
        textTheme: ButtonTextTheme.primary,
        //  <-- this auto selects the right color
        shape: StadiumBorder(),
        disabledColor: Color(0xFFE5E3DC),
      ),
      scaffoldBackgroundColor: const Color(0xFFFDFBEF),
      cardColor: const Color(0xFFFDFBEF),
      cardTheme: const CardTheme(elevation: 5),
      canvasColor: Colors.black,
      appBarTheme: AppBarTheme(
        color: const Color(0xFFFDFBEF).withOpacity(0.8),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xFF234958),
        ),
      ),
      textTheme: const TextTheme(
        headline4: TextStyle(fontWeight: FontWeight.w900),
        headline5: TextStyle(fontWeight: FontWeight.w900, fontSize: 25),
        headline6: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF234958),
          fontSize: 20,
        ),
        subtitle1: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF234958),
        ),
        subtitle2: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF234958),
        ),
        bodyText2: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        caption: TextStyle(fontSize: 13, color: Color(0xFF234958)),
        button: TextStyle(fontWeight: FontWeight.bold),
      ),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFFE28777)),
    );
  }
}

TextStyle appBarTitleStyle(BuildContext context) =>
    Theme.of(context).textTheme.subtitle1!.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        );

TextStyle textFieldLabelStyle(BuildContext context) =>
    Theme.of(context).textTheme.caption!.copyWith(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );

TextStyle textFieldHintStyle(BuildContext context) =>
    Theme.of(context).textTheme.caption!.copyWith(
          color: Theme.of(context).hintColor,
          fontWeight: FontWeight.normal,
          height: 3,
        );

TextStyle textFieldInputStyle(BuildContext context) =>
    Theme.of(context).textTheme.caption!.copyWith(
          color: Theme.of(context).primaryColor,
          fontSize: 15,
          fontWeight: FontWeight.normal,
        );
