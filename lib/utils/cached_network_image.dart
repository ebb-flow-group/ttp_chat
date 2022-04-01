import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config.dart';

ImageProvider cachedImageProvider(String? url) {
  if (url == null || url.isEmpty) {
    url = Config.kPlaceholderImg;
  }
  return CachedNetworkImageProvider(url);
}

CachedNetworkImage cachedImage(String? url, {double? height, double? width, BoxFit? fit}) {
  if (url == null || url.isEmpty) {
    url = Config.kPlaceholderImg;
  }
  return CachedNetworkImage(
    imageUrl: url,
    height: height,
    width: width,
    fit: fit ?? BoxFit.cover,
    progressIndicatorBuilder: (context, url, downloadProgress) =>
        Container(color: Colors.transparent, child: const Center(child: CupertinoActivityIndicator())),
    errorWidget: (context, url, error) => const Icon(Icons.error),
  );
}
