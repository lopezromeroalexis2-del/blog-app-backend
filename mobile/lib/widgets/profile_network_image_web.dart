import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class ProfileNetworkImage extends StatefulWidget {
  const ProfileNetworkImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  State<ProfileNetworkImage> createState() => _ProfileNetworkImageState();
}

class _ProfileNetworkImageState extends State<ProfileNetworkImage> {
  static int _nextViewId = 0;
  late final String _viewType;
  bool _failedToLoad = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'profile-image-${_nextViewId++}';
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (viewId) {
      final image = html.ImageElement()
        ..src = widget.imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.borderRadius = '50%';

      image.onError.listen((_) {
        if (mounted) {
          setState(() => _failedToLoad = true);
        }
      });
      return image;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failedToLoad) {
      return const Icon(Icons.person, size: 60, color: Colors.white);
    }

    return HtmlElementView(viewType: _viewType);
  }
}
