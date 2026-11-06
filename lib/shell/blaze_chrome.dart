import 'package:flutter/material.dart';

import '../theme.dart';

class BlazeChrome extends StatelessWidget {
  const BlazeChrome({
    super.key,
    required this.child,
    this.loading = false,
  });

  final Widget child;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: Column(
        children: [
          Material(
            color: BlazeTheme.panel,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Image.asset('assets/logo.png', width: 32, height: 32),
                      const SizedBox(width: 10),
                      const Text(
                        'Blaze Hosting',
                        style: TextStyle(
                          color: BlazeTheme.text,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0x22C94F59),
                          border: Border.all(color: const Color(0x73C94F59)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'ISOLATED',
                          style: TextStyle(
                            color: BlazeTheme.accentBright,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (loading)
            const LinearProgressIndicator(
              minHeight: 2,
              color: BlazeTheme.accentBright,
              backgroundColor: Colors.transparent,
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class BlazeSplash extends StatelessWidget {
  const BlazeSplash({super.key, this.message = 'Loading your servers…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 96, height: 96),
            const SizedBox(height: 18),
            const Text(
              'Blaze Hosting',
              style: TextStyle(
                color: BlazeTheme.text,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '1.0.0 · your account only',
              style: TextStyle(color: BlazeTheme.muted, fontSize: 13),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                color: BlazeTheme.accent,
                backgroundColor: Color(0x22FFFFFF),
              ),
            ),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: BlazeTheme.muted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
