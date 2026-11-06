import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../isolate/allowlist.dart';

class WebPanelFrame extends StatelessWidget {
  const WebPanelFrame({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Center(
        child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
          onPressed: () {
            final uri = Uri.parse(url);
            if (BlazeAllowlist.allows(uri)) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: const Text('Open panel'),
        ),
      ),
    );
  }
}
