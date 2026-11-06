import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

import '../isolate/allowlist.dart';

class WebPanelFrame extends StatelessWidget {
  const WebPanelFrame({super.key, required this.url});

  final String url;

  static var _registered = false;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url);
    final src = BlazeAllowlist.allows(uri) ? url : 'https://${BlazeAllowlist.panel}';
    if (!_registered) {
      ui_web.platformViewRegistry.registerViewFactory('blaze-panel-frame', (int viewId) {
        final iframe = html.IFrameElement()
          ..src = src
          ..allow = 'clipboard-read; clipboard-write; fullscreen'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframe;
      });
      _registered = true;
    }
    return const Scaffold(
      backgroundColor: Color(0xFF080808),
      body: HtmlElementView(viewType: 'blaze-panel-frame'),
    );
  }
}
