import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get_it/get_it.dart';
import 'package:ttp_chat/core/constants/enums.dart';
import 'package:ttp_chat/core/screens/chat_utils.dart';

/// This class is used to build dynamic links for the app.
class DeeplinkBuilder {
  static Uri get _baseUrl {
    switch (GetIt.I<ChatUtils>().env) {
      case Env.dev:
        return Uri.parse('https://tabletopdev.page.link');
      case Env.staging:
        return Uri.parse('https://tabletopstage.page.link');
      case Env.prod:
        return Uri.parse('https://tabletopapp.page.link');
    }
  }

  /// iOS Bundle ID for Tabletop Creators app
  static String get _iosBundleIdCreatorApp {
    switch (GetIt.I<ChatUtils>().env) {
      case Env.dev:
        return 'so.tabletop.brand-dev';
      case Env.staging:
        return 'so.tabletop.brand-stage';
      case Env.prod:
        return 'so.tabletop.brand';
    }
  }

  /// Android package name for Tabletop Creators app
  static String get _androidPackageNameCreatorApp {
    switch (GetIt.I<ChatUtils>().env) {
      case Env.dev:
        return 'so.tabletop.brand.dev';
      case Env.staging:
        return 'so.tabletop.brand.stage';
      case Env.prod:
        return 'so.tabletop.brand';
    }
  }

  /// iOS Bundle ID for Tabletop main app
  static String get _iosBundleIdMainApp {
    switch (GetIt.I<ChatUtils>().env) {
      case Env.dev:
        return 'co.tabletop.app-dev';
      case Env.staging:
        return 'co.tabletop.app-stage';
      case Env.prod:
        return 'co.tabletop.app';
    }
  }

  /// Android package name for Tabletop main app
  static String get _androidPackageNameMainApp {
    switch (GetIt.I<ChatUtils>().env) {
      case Env.dev:
        return 'co.tabletop.app.dev';
      case Env.staging:
        return 'co.tabletop.app.stage';
      case Env.prod:
        return 'co.tabletop.app';
    }
  }

  static String get _baseMainAppWebUrl {
    switch (GetIt.I<ChatUtils>().env) {
      case Env.dev:
        // No public URL for dev environment. Use the same web URL from the stage environment.
        return 'https://stage.tabletop.so';
      case Env.staging:
        return 'https://stage.tabletop.so';
      case Env.prod:
        return 'https://tabletop.so/';
    }
  }

  /// Create a dynamic link.
  /// [path] ...
  /// [fallbackWebUrl] is the url that will be opened when the app is not installed.
  /// [short] is a boolean to determine if the link should be short or long.
  /// [isMainApp] is true if the link is for the main app, false if it is for the creator app.
  static Future<Uri?> build({
    required String path,
    String fallbackWebUrl = 'https://tabletop.so',
    String? imgUrl,
    String? title,
    String? description,
    bool short = true,
    bool isMainApp = true,
  }) async {
    String androidPackageName = isMainApp ? _androidPackageNameMainApp : _androidPackageNameCreatorApp;
    String iosBundleId = isMainApp ? _iosBundleIdMainApp : _iosBundleIdCreatorApp;

    Uri? longDynamicLink = Uri(
      scheme: _baseUrl.scheme,
      host: _baseUrl.host,
      queryParameters: {
        'link': '$_baseUrl$path', // Dynamic link
        'afl': fallbackWebUrl, // Android fallback link
        'ifl': fallbackWebUrl, // iOS fallback link
        'ofl': fallbackWebUrl, // Link for other platforms
        'apn': androidPackageName, // Android package name
        'ibi': iosBundleId, // iOS bundle identifier
        'st': title, // Social title
        'sd': description, // Social description
        'si': imgUrl, // Social image
        //'efr': '1', // Skip Preview page on iOS
      },
    );

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: '$_baseUrl',
      longDynamicLink: longDynamicLink,
      link: Uri.parse('$_baseUrl$path'),
      androidParameters: AndroidParameters(packageName: androidPackageName, fallbackUrl: Uri.parse(fallbackWebUrl)),
      iosParameters: IOSParameters(bundleId: iosBundleId, fallbackUrl: Uri.parse(fallbackWebUrl)),
    );

    // Return short link
    if (short) {
      final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      return shortLink.shortUrl;
    }

    // Return long link
    return await FirebaseDynamicLinks.instance.buildLink(parameters);
  }

  /// Build a dynamic link for Creator profile on Tabletop Main app.
  static Future<Uri?> buildCreatorProfileLink({
    required String username,
    int? id,
    String? imgUrl,
    String? title,
    String? description,
    bool short = true,
  }) async {
    return await build(
      path: '/home-brand/$username',
      fallbackWebUrl: '$_baseMainAppWebUrl/$username',
      imgUrl: imgUrl,
      title: title,
      description: description,
      short: short,
      isMainApp: true, // Always open in Main app
    );
  }
}
