import 'package:flutter/material.dart';

import '../theme.dart';

const blazeFill = OutlineInputBorder(
  borderSide: BorderSide(color: BlazeTheme.line),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

const blazeFocus = OutlineInputBorder(
  borderSide: BorderSide(color: BlazeTheme.accent),
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

InputDecoration blazeField(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: BlazeTheme.muted),
      enabledBorder: blazeFill,
      focusedBorder: blazeFocus,
    );

class BlazeBtn extends StatelessWidget {
  const BlazeBtn({super.key, required this.label, required this.onTap, this.busy = false});
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: BlazeTheme.accent, foregroundColor: const Color(0xFF1A0709)),
        onPressed: busy ? null : onTap,
        child: Text(busy ? 'Working…' : label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class Pwr extends StatelessWidget {
  const Pwr(this.label, this.color, this.onTap, {super.key});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: const StadiumBorder(),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

Future<void> blazeAlert(BuildContext context, String msg) {
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: BlazeTheme.panel,
      title: const Text('Blaze Hosting', style: TextStyle(color: BlazeTheme.text)),
      content: Text(msg, style: const TextStyle(color: BlazeTheme.muted)),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
    ),
  );
}

String cleanErr(Object e) => e.toString().replaceFirst('Exception: ', '');
