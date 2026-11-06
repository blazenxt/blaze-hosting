import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

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
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: EmberBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: wide
                  ? Row(
                      children: [
                        const Expanded(child: _Hero()),
                        const SizedBox(width: 36),
                        SizedBox(width: 420, child: _form()),
                      ],
                    )
                  : _form(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/logo.png', width: 44, height: 44),
          const SizedBox(height: 16),
          const Text('Login to continue', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1, color: BlazeTheme.text)),
          const SizedBox(height: 6),
          const Text('Sign in with your Blaze Hosting account.', style: TextStyle(color: BlazeTheme.muted)),
          const SizedBox(height: 22),
          TextField(
            controller: user,
            style: const TextStyle(color: BlazeTheme.text),
            decoration: blazeField('Username or email'),
            onSubmitted: (_) => widget.onSubmit(user.text.trim(), pass.text),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: pass,
            obscureText: true,
            style: const TextStyle(color: BlazeTheme.text),
            decoration: blazeField('Password'),
            onSubmitted: (_) => widget.onSubmit(user.text.trim(), pass.text),
          ),
          if (widget.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(widget.error, style: const TextStyle(color: BlazeTheme.bad)),
            ),
          const SizedBox(height: 18),
          BlazeBtn(label: 'Login', busy: widget.busy, onTap: () => widget.onSubmit(user.text.trim(), pass.text)),
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                onPressed: widget.onCreate,
                child: const Text('Create account', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              const Text('Blaze Hosting © 2026', style: TextStyle(color: BlazeTheme.muted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const IsolatedChip(),
        const SizedBox(height: 18),
        const Text(
          'Game servers.\nInstant control.',
          style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, letterSpacing: -2, height: 1.02, color: BlazeTheme.text),
        ),
        const SizedBox(height: 14),
        const Text(
          'The same ember shell as the panel — console, files, variables, backups. Isolated to your account on panel.nawazfx.com.',
          style: TextStyle(color: BlazeTheme.muted, fontSize: 16, height: 1.45),
        ),
        const SizedBox(height: 28),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  _MiniTab(true, 'Console'),
                  _MiniTab(false, 'Files'),
                  _MiniTab(false, 'Variables'),
                  _MiniTab(false, 'Backups'),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                '[Blaze] server process starting (Node 22)\nListening on 0.0.0.0:25565',
                style: TextStyle(fontFamily: 'Consolas', fontSize: 12.5, color: Color(0xFFD1D5DB), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniTab extends StatelessWidget {
  const _MiniTab(this.on, this.label);
  final bool on;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: on ? const Color(0x2EC94F59) : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: on ? const Color(0x80C94F59) : BlazeTheme.line),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: on ? BlazeTheme.accentBright : BlazeTheme.muted)),
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
    widget.onSubmit(
      first: first.text.trim(),
      last: last.text.trim(),
      username: user.text.trim(),
      email: email.text.trim(),
      password: pass.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final err = local.isNotEmpty ? local : widget.error;
    return Scaffold(
      body: EmberBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassCard(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(onPressed: widget.onBack, child: const Text('← Sign in', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700))),
                    ),
                    Image.asset('assets/logo.png', width: 48, height: 48),
                    const SizedBox(height: 12),
                    const Text('Create your account', style: TextStyle(color: BlazeTheme.text, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
                    const SizedBox(height: 6),
                    const Text('Isolated to panel.nawazfx.com. Your servers only.', style: TextStyle(color: BlazeTheme.muted)),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(child: TextField(controller: first, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('First name'))),
                      const SizedBox(width: 10),
                      Expanded(child: TextField(controller: last, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Last name'))),
                    ]),
                    const SizedBox(height: 12),
                    TextField(controller: user, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Username')),
                    const SizedBox(height: 12),
                    TextField(controller: email, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Email')),
                    const SizedBox(height: 12),
                    TextField(controller: pass, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Password')),
                    const SizedBox(height: 12),
                    TextField(controller: confirm, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Confirm password')),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: terms,
                      onChanged: (v) => setState(() => terms = v ?? false),
                      activeColor: BlazeTheme.accent,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'I agree to the Terms — no abuse, no card testing, no VPS-like services.',
                        style: TextStyle(color: BlazeTheme.muted, fontSize: 12),
                      ),
                    ),
                    if (err.isNotEmpty) Text(err, style: const TextStyle(color: BlazeTheme.bad)),
                    const SizedBox(height: 8),
                    BlazeBtn(label: 'Create account', busy: widget.busy, onTap: _go),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
