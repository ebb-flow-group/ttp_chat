import 'package:flutter/material.dart';
import 'package:ttp_chat/core/services/ts.dart';

import '../../../../config.dart';
import '../../../../utils/cached_network_image.dart';
import '../../widgets/helpers.dart';

class SearchTileAvatar extends StatelessWidget {
  final double radius;
  final String? url;
  final String? name;
  const SearchTileAvatar(this.url, {this.name, this.radius = 20, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var color = Colors.white;

    final hasImage = url != null && url != '';

    return Container(
      height: radius * 2,
      width: radius * 2,
      decoration: BoxDecoration(
          color: color,
          image: !hasImage ? null : DecorationImage(image: cachedImageProvider(url), fit: BoxFit.cover),
          shape: BoxShape.circle,
          gradient: Config.tabletopGradient),
      child: !hasImage
          ? Center(
              child: Text(
                getInitials(name ?? ""),
                style: Ts.h3Bold(Config.creameryColor),
              ),
            )
          : null,
    );
  }
}
