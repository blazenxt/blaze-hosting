import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'widgets.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, required this.api, required this.onBack});
  final BlazeApi api;
  final VoidCallback onBack;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<BlazeApiKey> keys = [];
  String err = '';
  bool busy = false;
  final current = TextEditingController();
  final next = TextEditingController();
  final keyName = TextEditingController(text: 'Blaze Hosting desktop');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    current.dispose();
    next.dispose();
    keyName.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      keys = await widget.api.apiKeys();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => err = cleanErr(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.api.account;
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: widget.onBack, child: const Text('← Servers', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700))),
            ),
            const Text('Account', style: TextStyle(color: BlazeTheme.text, fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(a == null ? widget.api.email : '${a.name} · ${a.username}\n${a.email}', style: const TextStyle(color: BlazeTheme.muted)),
            const SizedBox(height: 22),
            const Text('Change password', style: TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            TextField(controller: current, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Current password')),
            const SizedBox(height: 10),
            TextField(controller: next, obscureText: true, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('New password')),
            const SizedBox(height: 10),
            BlazeBtn(
              label: 'Update password',
              busy: busy,
              onTap: () async {
                setState(() => busy = true);
                try {
                  await widget.api.changePassword(current.text, next.text);
                  if (mounted) await blazeAlert(context, 'Password updated.');
                } catch (e) {
                  if (mounted) await blazeAlert(context, cleanErr(e));
                } finally {
                  if (mounted) setState(() => busy = false);
                }
              },
            ),
            const SizedBox(height: 28),
            const Text('API keys', style: TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            TextField(controller: keyName, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Key description')),
            const SizedBox(height: 10),
            BlazeBtn(
              label: 'Create API key',
              onTap: () async {
                try {
                  final k = await widget.api.createApiKey(keyName.text.trim());
                  if (k.token != null && k.token!.isNotEmpty) {
                    await Clipboard.setData(ClipboardData(text: k.token!));
                    if (mounted) await blazeAlert(context, 'Key created and copied:\n${k.token}');
                  }
                  await _load();
                } catch (e) {
                  if (mounted) await blazeAlert(context, cleanErr(e));
                }
              },
            ),
            const SizedBox(height: 12),
            ...keys.map(
              (k) => ListTile(
                title: Text(k.description, style: const TextStyle(color: BlazeTheme.text)),
                subtitle: Text(k.identifier, style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFB7185)),
                  onPressed: () async {
                    await widget.api.deleteApiKey(k.identifier);
                    await _load();
                  },
                ),
              ),
            ),
            if (err.isNotEmpty) Text(err, style: const TextStyle(color: Color(0xFFFB7185))),
          ],
        ),
      ),
    );
  }
}
