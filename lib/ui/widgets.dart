import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../api/models.dart';
import '../theme.dart';

const announceText =
    'New: the corner chat is your isolated agent — create servers and debug crashes on your account only.';

InputDecoration blazeField(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: BlazeTheme.muted, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF141619),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BlazeTheme.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: BlazeTheme.accent),
      ),
    );

class AnnounceBar extends StatelessWidget {
  const AnnounceBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0E1014),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        children: [
          Container(width: 3, height: 16, color: BlazeTheme.accent),
          const SizedBox(width: 10),
          const Text('New: ', style: TextStyle(color: BlazeTheme.accent, fontWeight: FontWeight.w800)),
          const Expanded(
            child: Text(
              'the corner chat is your isolated agent — create servers and debug crashes on your account only.',
              style: TextStyle(color: BlazeTheme.text, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class BlazeBtn extends StatelessWidget {
  const BlazeBtn({super.key, required this.label, required this.onTap, this.busy = false});
  final String label;
  final VoidCallback? onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: BlazeTheme.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: busy ? null : onTap,
        child: Text(busy ? 'Working…' : label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class StatusOrb extends StatelessWidget {
  const StatusOrb(this.state, {super.key, this.size = 8});
  final String state;
  final double size;

  Color get color {
    if (state == 'running') return BlazeTheme.ok;
    if (state == 'starting' || state == 'stopping') return BlazeTheme.warn;
    return BlazeTheme.bad;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 6)]),
    );
  }
}

class Gauge extends StatelessWidget {
  const Gauge({super.key, required this.label, required this.value, required this.color, this.caption = ''});
  final String label;
  final double value;
  final Color color;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).clamp(0, 999);
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: CustomPaint(
              painter: _RingPainter(value.clamp(0, 1), color),
              child: Center(
                child: Text('${pct.round()}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BlazeTheme.text)),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: BlazeTheme.muted, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    final bg = Paint()
      ..color = const Color(0xFF2A2E35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * value, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.value != value || old.color != color;
}

class PanelShell extends StatelessWidget {
  const PanelShell({
    super.key,
    required this.email,
    required this.username,
    required this.servers,
    required this.states,
    required this.currentId,
    required this.section,
    required this.onHome,
    required this.onOpen,
    required this.onAccount,
    required this.onLogout,
    required this.child,
  });

  final String email;
  final String username;
  final List<BlazeServer> servers;
  final Map<String, String> states;
  final String? currentId;
  final String section;
  final VoidCallback onHome;
  final ValueChanged<BlazeServer> onOpen;
  final VoidCallback onAccount;
  final VoidCallback onLogout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: Column(
        children: [
          const AnnounceBar(),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 248,
                  child: _Side(
                    email: email,
                    username: username,
                    servers: servers,
                    states: states,
                    currentId: currentId,
                    onHome: onHome,
                    onOpen: onOpen,
                    onAccount: onAccount,
                    onLogout: onLogout,
                  ),
                ),
                const VerticalDivider(width: 1, color: BlazeTheme.line),
                Expanded(child: ColoredBox(color: BlazeTheme.bg, child: child)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Side extends StatefulWidget {
  const _Side({
    required this.email,
    required this.username,
    required this.servers,
    required this.states,
    required this.currentId,
    required this.onHome,
    required this.onOpen,
    required this.onAccount,
    required this.onLogout,
  });
  final String email;
  final String username;
  final List<BlazeServer> servers;
  final Map<String, String> states;
  final String? currentId;
  final VoidCallback onHome;
  final ValueChanged<BlazeServer> onOpen;
  final VoidCallback onAccount;
  final VoidCallback onLogout;

  @override
  State<_Side> createState() => _SideState();
}

class _SideState extends State<_Side> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final list = widget.servers.where((s) => q.isEmpty || s.name.toLowerCase().contains(q.toLowerCase())).toList();
    return ColoredBox(
      color: const Color(0xFF0E1013),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onHome,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', width: 28, height: 28),
                  const SizedBox(width: 8),
                  const Text('BlazeNXT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: BlazeTheme.text)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0x22C94F59), borderRadius: BorderRadius.circular(4)),
                    child: const Text('PANEL', style: TextStyle(color: BlazeTheme.accentBright, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: (v) => setState(() => q = v),
              style: const TextStyle(color: BlazeTheme.text, fontSize: 13),
              decoration: blazeField('Search...').copyWith(labelText: null, hintText: 'Search...', hintStyle: const TextStyle(color: BlazeTheme.muted)),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text('SERVERS', style: TextStyle(color: BlazeTheme.muted, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: list
                  .map(
                    (s) => InkWell(
                      onTap: () => widget.onOpen(s),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        decoration: BoxDecoration(
                          color: widget.currentId == s.id ? const Color(0xFF282C32) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            StatusOrb(widget.states[s.id] ?? 'offline'),
                            const SizedBox(width: 10),
                            Expanded(child: Text(s.name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BlazeTheme.text, fontSize: 13, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const Divider(height: 1, color: BlazeTheme.line),
          InkWell(
            onTap: widget.onAccount,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: BlazeTheme.accent,
                    child: Text(
                      (widget.username.isNotEmpty ? widget.username[0] : 'U').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.username.isNotEmpty ? widget.username : widget.email, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  IconButton(onPressed: widget.onLogout, icon: const Icon(Icons.logout, size: 16, color: BlazeTheme.muted), visualDensity: VisualDensity.compact),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> blazeAlert(BuildContext context, String msg) {
  return showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: BlazeTheme.card,
      title: const Text('Blaze Hosting', style: TextStyle(color: BlazeTheme.text)),
      content: Text(msg, style: const TextStyle(color: BlazeTheme.muted)),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK'))],
    ),
  );
}

String cleanErr(Object e) => e.toString().replaceFirst('Exception: ', '');
