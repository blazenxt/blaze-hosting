import 'package:flutter/material.dart';

import '../theme.dart';

InputDecoration blazeField(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: BlazeTheme.muted, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0C0C10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BlazeTheme.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: BlazeTheme.accent, width: 1.4),
      ),
    );

class EmberBackdrop extends StatelessWidget {
  const EmberBackdrop({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: BlazeTheme.bg),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.05),
              radius: 1.15,
              colors: [Color(0x38C94F59), Color(0x00070708)],
            ),
          ),
        ),
        CustomPaint(painter: _DotGrid(), size: Size.infinite),
        child,
      ],
    );
  }
}

class _DotGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0x0AFFFFFF);
    for (double y = 0; y < size.height; y += 28) {
      for (double x = 0; x < size.width; x += 28) {
        canvas.drawCircle(Offset(x, y), 1, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(18), this.onTap});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BlazeTheme.line),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x0DFFFFFF), Color(0xEB101014)],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return box;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: box),
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
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF08A90), Color(0xFFC94F59)],
          ),
          boxShadow: const [BoxShadow(color: Color(0x47C94F59), blurRadius: 28, offset: Offset(0, 10))],
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: BlazeTheme.ink,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: busy ? null : onTap,
          child: Text(busy ? 'Working…' : label, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
        ),
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
        backgroundColor: color.withOpacity(0.08),
        side: BorderSide(color: color.withOpacity(0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

class StatusOrb extends StatelessWidget {
  const StatusOrb(this.state, {super.key});
  final String state;

  Color get color {
    if (state == 'running') return BlazeTheme.ok;
    if (state == 'starting' || state == 'stopping') return BlazeTheme.warn;
    return BlazeTheme.bad;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 10)],
      ),
    );
  }
}

class IsolatedChip extends StatelessWidget {
  const IsolatedChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0x1FC94F59),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: const Color(0x73C94F59)),
      ),
      child: const Text(
        'ISOLATED',
        style: TextStyle(color: BlazeTheme.accentBright, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.4),
      ),
    );
  }
}

class PillTabs extends StatelessWidget {
  const PillTabs({super.key, required this.tabs, required this.index, required this.onSelect});
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => onSelect(i),
                borderRadius: BorderRadius.circular(99),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: i == index ? const Color(0x2EC94F59) : const Color(0x0AFFFFFF),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: i == index ? const Color(0x80C94F59) : BlazeTheme.line),
                  ),
                  child: Text(
                    tabs[i],
                    style: TextStyle(
                      color: i == index ? BlazeTheme.accentBright : BlazeTheme.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PanelShell extends StatelessWidget {
  const PanelShell({
    super.key,
    required this.email,
    required this.section,
    required this.onServers,
    required this.onAccount,
    required this.onLogout,
    required this.child,
  });

  final String email;
  final String section;
  final VoidCallback onServers;
  final VoidCallback onAccount;
  final VoidCallback onLogout;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 880;
    final rail = _Rail(email: email, section: section, onServers: onServers, onAccount: onAccount, onLogout: onLogout, compact: !wide);
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: EmberBackdrop(
        child: wide
            ? Row(
                children: [
                  SizedBox(width: 232, child: rail),
                  const VerticalDivider(width: 1, color: BlazeTheme.line),
                  Expanded(child: child),
                ],
              )
            : Column(
                children: [
                  rail,
                  const Divider(height: 1, color: BlazeTheme.line),
                  Expanded(child: child),
                ],
              ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.email,
    required this.section,
    required this.onServers,
    required this.onAccount,
    required this.onLogout,
    required this.compact,
  });
  final String email;
  final String section;
  final VoidCallback onServers;
  final VoidCallback onAccount;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final nav = [
      _Nav(Icons.dns_outlined, 'Servers', section == 'servers', onServers),
      _Nav(Icons.person_outline, 'Account', section == 'account', onAccount),
    ];
    if (compact) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          children: [
            Image.asset('assets/logo.png', width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('Blaze Hosting', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            ...nav,
            IconButton(onPressed: onLogout, icon: const Icon(Icons.logout, size: 18, color: BlazeTheme.muted)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/logo.png', width: 40, height: 40)),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Blaze Hosting', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                    Text('panel.nawazfx.com', style: TextStyle(color: BlazeTheme.muted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const IsolatedChip(),
          const SizedBox(height: 22),
          ...nav.map((n) => Padding(padding: const EdgeInsets.only(bottom: 6), child: n)),
          const Spacer(),
          Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
          const SizedBox(height: 8),
          TextButton(onPressed: onLogout, child: const Text('Log out', style: TextStyle(color: BlazeTheme.muted))),
        ],
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav(this.icon, this.label, this.active, this.onTap);
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0x24C94F59) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? const Color(0x55C94F59) : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: active ? BlazeTheme.accentBright : BlazeTheme.muted),
            const SizedBox(width: 10),
            Text(label, style: TextStyle(color: active ? BlazeTheme.text : BlazeTheme.muted, fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
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
