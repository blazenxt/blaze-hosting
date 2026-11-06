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
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 64, height: 64),
                const SizedBox(height: 14),
                const Text('Welcome back.', style: TextStyle(color: BlazeTheme.text, fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Only your servers. Only your account.', style: TextStyle(color: BlazeTheme.muted)),
                const SizedBox(height: 22),
                TextField(controller: user, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Email or username')),
                const SizedBox(height: 12),
                TextField(controller: pass, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Password')),
                if (widget.error.isNotEmpty)
                  Padding(padding: const EdgeInsets.only(top: 10), child: Text(widget.error, style: const TextStyle(color: Color(0xFFFB7185)))),
                const SizedBox(height: 16),
                BlazeBtn(label: 'Sign in', busy: widget.busy, onTap: () => widget.onSubmit(user.text.trim(), pass.text)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onCreate,
                  child: const Text('Create account', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
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
      backgroundColor: BlazeTheme.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: widget.onBack, child: const Text('← Sign in', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700))),
                ),
                Image.asset('assets/logo.png', width: 56, height: 56),
                const SizedBox(height: 12),
                const Text('Create your account', style: TextStyle(color: BlazeTheme.text, fontSize: 26, fontWeight: FontWeight.w700)),
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
                const SizedBox(height: 10),
                CheckboxListTile(
                  value: terms,
                  onChanged: (v) => setState(() => terms = v ?? false),
                  activeColor: BlazeTheme.accent,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'I agree to the Terms — no abuse, no card testing, no VPS-like services.',
                    style: TextStyle(color: BlazeTheme.muted, fontSize: 12),
                  ),
                ),
                if (err.isNotEmpty) Text(err, style: const TextStyle(color: Color(0xFFFB7185))),
                const SizedBox(height: 8),
                BlazeBtn(label: 'Create account', busy: widget.busy, onTap: _go),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
