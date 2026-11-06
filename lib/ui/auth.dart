import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

class _HeroAuth extends StatelessWidget {
  const _HeroAuth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/login-hero.png', fit: BoxFit.cover),
          const ColoredBox(color: Color(0x66000000)),
          Column(
            children: [
              const AnnounceBar(),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: child,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('BlazeNXT © 2026', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
        decoration: BoxDecoration(
          color: const Color(0xE6111318),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
        child: child,
      ),
    );
  }
}

class _BrandHead extends StatelessWidget {
  const _BrandHead({required this.heading, required this.kicker});
  final String heading;
  final String kicker;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/logo.png', width: 56, height: 56),
        const SizedBox(height: 10),
        const Text('BlazeNXT', style: TextStyle(color: BlazeTheme.accent, fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 14),
        const Text(
          'Game servers. Instant control.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.6),
        ),
        const SizedBox(height: 18),
        Text(heading, style: const TextStyle(color: BlazeTheme.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(kicker, style: const TextStyle(color: BlazeTheme.muted, fontSize: 13)),
        const SizedBox(height: 18),
      ],
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.busy, required this.error, required this.onSubmit, required this.onCreate});
  final bool busy;
  final String error;
  final void Function(String, String) onSubmit;
  final VoidCallback onCreate;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final pass = TextEditingController();

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _HeroAuth(
      child: _AuthCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BrandHead(heading: 'Login to Continue', kicker: 'Sign in with your BlazeNXT account.'),
            TextField(controller: user, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Username or Email')),
            const SizedBox(height: 12),
            TextField(controller: pass, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Password'), onSubmitted: (_) => widget.onSubmit(user.text.trim(), pass.text)),
            if (widget.error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(widget.error, style: const TextStyle(color: BlazeTheme.bad))),
            const SizedBox(height: 16),
            BlazeBtn(label: 'Login', busy: widget.busy, onTap: () => widget.onSubmit(user.text.trim(), pass.text)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onCreate,
              child: const Text('Create account', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.busy, required this.error, required this.onSubmit, required this.onBack});
  final bool busy;
  final String error;
  final Future<void> Function({
    required String first,
    required String last,
    required String username,
    required String email,
    required String password,
  }) onSubmit;
  final VoidCallback onBack;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final first = TextEditingController();
  final last = TextEditingController();
  final user = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();
  bool terms = false;
  String local = '';

  @override
  void dispose() {
    first.dispose();
    last.dispose();
    user.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    super.dispose();
  }

  void _go() {
    setState(() => local = '');
    if (!terms) {
      setState(() => local = 'Accept the terms to create an account.');
      return;
    }
    if (pass.text != confirm.text) {
      setState(() => local = 'Passwords do not match.');
      return;
    }
    if (user.text.trim().isEmpty || email.text.trim().isEmpty || pass.text.length < 8) {
      setState(() => local = 'Username, email, and 8+ character password required.');
      return;
    }
    widget.onSubmit(first: first.text.trim(), last: last.text.trim(), username: user.text.trim(), email: email.text.trim(), password: pass.text);
  }

  @override
  Widget build(BuildContext context) {
    final err = local.isNotEmpty ? local : widget.error;
    return _HeroAuth(
      child: _AuthCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BrandHead(heading: 'Create your account', kicker: 'Sign in with your BlazeNXT account.'),
            Row(children: [
              Expanded(child: TextField(controller: first, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('First Name'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: last, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Last Name'))),
            ]),
            const SizedBox(height: 12),
            TextField(controller: user, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Username')),
            const SizedBox(height: 12),
            TextField(controller: email, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Email')),
            const SizedBox(height: 12),
            TextField(controller: pass, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Password')),
            const SizedBox(height: 12),
            TextField(controller: confirm, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Confirm Password')),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: terms,
              onChanged: (v) => setState(() => terms = v ?? false),
              activeColor: BlazeTheme.accent,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'I have read and agree to the Terms & Conditions — including plan limits and acceptable use.',
                style: TextStyle(color: BlazeTheme.muted, fontSize: 11, height: 1.35),
              ),
            ),
            if (err.isNotEmpty) Text(err, style: const TextStyle(color: BlazeTheme.bad, fontSize: 12)),
            const SizedBox(height: 8),
            BlazeBtn(label: 'Create Account', busy: widget.busy, onTap: _go),
            const SizedBox(height: 8),
            TextButton(onPressed: widget.onBack, child: const Text('Already have an account? Login', style: TextStyle(color: BlazeTheme.muted))),
          ],
        ),
      ),
    );
  }
}
