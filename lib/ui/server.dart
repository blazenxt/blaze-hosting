import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'widgets.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key, required this.server, required this.api, required this.onBack});
  final BlazeServer server;
  final BlazeApi api;
  final VoidCallback onBack;

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  int tab = 0;
  static const tabs = [
    (Icons.terminal, 'Console'),
    (Icons.folder_outlined, 'Files'),
    (Icons.storage_outlined, 'Databases'),
    (Icons.backup_outlined, 'Backups'),
    (Icons.lan_outlined, 'Network'),
    (Icons.tune, 'Startup'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.server;
    final pages = [
      _Console(server: s, api: widget.api),
      _Files(server: s, api: widget.api),
      _Dbs(server: s, api: widget.api),
      _Backups(server: s, api: widget.api),
      _Net(server: s, api: widget.api),
      _Vars(server: s, api: widget.api),
      _Settings(server: s, api: widget.api),
    ];
    return Row(
      children: [
        Container(
          width: 200,
          color: const Color(0xFF0C0E12),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(s.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              ),
              for (var i = 0; i < tabs.length; i++)
                InkWell(
                  onTap: () => setState(() => tab = i),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      color: tab == i ? const Color(0xFF282C32) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(tabs[i].$1, size: 16, color: tab == i ? BlazeTheme.text : BlazeTheme.muted),
                        const SizedBox(width: 10),
                        Text(tabs[i].$2, style: TextStyle(color: tab == i ? BlazeTheme.text : BlazeTheme.muted, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const VerticalDivider(width: 1, color: BlazeTheme.line),
        Expanded(child: pages[tab]),
      ],
    );
  }
}

class _Console extends StatefulWidget {
  const _Console({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Console> createState() => _ConsoleState();
}

class _ConsoleState extends State<_Console> {
  final logs = <String>[];
  final cmd = TextEditingController();
  WebSocketChannel? ch;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    final sock = await widget.api.console(widget.server.id);
    if (!mounted || sock == null) return;
    ch = sock;
    sock.stream.listen((raw) {
      try {
        final msg = jsonDecode(raw is String ? raw : utf8.decode(raw as List<int>)) as Map;
        final event = '${msg['event']}';
        if (event == 'auth success') {
          sock.sink.add(jsonEncode({'event': 'send logs', 'args': [null]}));
        }
        if (event == 'console output' || event == 'install output') {
          final args = msg['args'];
          final line = args is List && args.isNotEmpty ? '${args.first}' : '';
          setState(() {
            logs.add(line);
            if (logs.length > 500) logs.removeAt(0);
          });
        }
      } catch (_) {}
    }, onError: (_) {}, onDone: () {});
  }

  @override
  void dispose() {
    ch?.sink.close();
    cmd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.server;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 10),
          child: Row(children: [
            Pwr('Start', BlazeTheme.ok, () => widget.api.power(s.id, 'start')),
            const SizedBox(width: 8),
            Pwr('Restart', BlazeTheme.accentBright, () => widget.api.power(s.id, 'restart')),
            const SizedBox(width: 8),
            Pwr('Stop', BlazeTheme.bad, () => widget.api.power(s.id, 'stop')),
            const SizedBox(width: 8),
            Pwr('Kill', BlazeTheme.warn, () => widget.api.power(s.id, 'kill')),
            const Spacer(),
            const Text('backup · logs · power', style: TextStyle(color: BlazeTheme.muted, fontSize: 12)),
          ]),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF050506),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BlazeTheme.line),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: SelectableText(
                logs.isEmpty ? 'Waiting for console…' : logs.join(),
                style: const TextStyle(fontFamily: 'Consolas', fontSize: 12.5, color: Color(0xFFD1D5DB), height: 1.45),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
          child: TextField(
            controller: cmd,
            style: const TextStyle(color: BlazeTheme.text, fontFamily: 'monospace'),
            decoration: blazeField('Send command').copyWith(suffixIcon: IconButton(
              icon: const Icon(Icons.send, color: BlazeTheme.accentBright),
              onPressed: () async {
                final t = cmd.text.trim();
                if (t.isEmpty) return;
                cmd.clear();
                await widget.api.command(s.id, t);
              },
            )),
            onSubmitted: (t) async {
              if (t.trim().isEmpty) return;
              cmd.clear();
              await widget.api.command(s.id, t.trim());
            },
          ),
        ),
      ],
    );
  }
}

class _Files extends StatefulWidget {
  const _Files({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Files> createState() => _FilesState();
}

class _FilesState extends State<_Files> {
  String dir = '/';
  List<BlazeFile> items = [];
  String? editing;
  final editor = TextEditingController();
  String err = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    editor.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      items = await widget.api.files(widget.server.id, dir);
      items.sort((a, b) {
        if (a.isFile != b.isFile) return a.isFile ? 1 : -1;
        return a.name.compareTo(b.name);
      });
      setState(() => err = '');
    } catch (e) {
      setState(() => err = cleanErr(e));
    }
  }

  String join(String name) => dir == '/' ? '/$name' : '$dir/$name';

  @override
  Widget build(BuildContext context) {
    if (editing != null) {
      return Column(
        children: [
          ListTile(
            title: Text(editing!, style: const TextStyle(color: BlazeTheme.text)),
            leading: IconButton(icon: const Icon(Icons.close, color: BlazeTheme.muted), onPressed: () => setState(() => editing = null)),
            trailing: TextButton(
              onPressed: () async {
                await widget.api.writeFile(widget.server.id, editing!, editor.text);
                setState(() => editing = null);
                await _load();
              },
              child: const Text('Save'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: editor,
                maxLines: null,
                expands: true,
                style: const TextStyle(color: BlazeTheme.text, fontFamily: 'monospace', fontSize: 12),
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        ListTile(
          title: Text(dir, style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
          leading: dir == '/'
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_upward, color: BlazeTheme.accentBright),
                  onPressed: () {
                    final parts = dir.split('/')..removeWhere((e) => e.isEmpty);
                    if (parts.isNotEmpty) parts.removeLast();
                    dir = parts.isEmpty ? '/' : '/${parts.join('/')}';
                    _load();
                  },
                ),
          trailing: IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, color: BlazeTheme.accentBright),
            onPressed: () async {
              final name = await _prompt(context, 'New folder');
              if (name == null || name.isEmpty) return;
              await widget.api.mkdir(widget.server.id, dir, name);
              await _load();
            },
          ),
        ),
        if (err.isNotEmpty) Padding(padding: const EdgeInsets.all(8), child: Text(err, style: const TextStyle(color: Color(0xFFFB7185)))),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) {
              final f = items[i];
              return ListTile(
                leading: Icon(f.isFile ? Icons.insert_drive_file_outlined : Icons.folder, color: BlazeTheme.accentBright),
                title: Text(f.name, style: const TextStyle(color: BlazeTheme.text)),
                subtitle: Text(f.isFile ? '${f.size} B' : 'Folder', style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
                onTap: () async {
                  if (!f.isFile) {
                    dir = join(f.name);
                    await _load();
                    return;
                  }
                  try {
                    editor.text = await widget.api.fileContents(widget.server.id, join(f.name));
                    setState(() => editing = join(f.name));
                  } catch (e) {
                    if (mounted) await blazeAlert(context, cleanErr(e));
                  }
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFFB7185)),
                  onPressed: () async {
                    await widget.api.deleteFiles(widget.server.id, dir, [f.name]);
                    await _load();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Vars extends StatefulWidget {
  const _Vars({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Vars> createState() => _VarsState();
}

class _VarsState extends State<_Vars> {
  List<BlazeVariable> vars = [];
  Map<String, String> dotenv = {};
  final ctrls = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    vars = await widget.api.variables(widget.server.id);
    dotenv = await widget.api.envFromDotenv(widget.server.id);
    for (final v in vars) {
      ctrls[v.env]?.dispose();
      ctrls[v.env] = TextEditingController(text: v.value);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final known = vars.map((v) => v.env).toSet();
    final extra = dotenv.keys.where((k) => !known.contains(k)).toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (dotenv.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('.env detected (${dotenv.length} keys)', style: const TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700)),
          ),
        ...vars.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(v.name, style: const TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w600)),
                Text('${v.env}${v.description.isEmpty ? '' : ' · ${v.description}'}', style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
                const SizedBox(height: 6),
                TextField(
                  controller: ctrls[v.env],
                  enabled: v.editable,
                  style: const TextStyle(color: BlazeTheme.text),
                  decoration: blazeField(v.env).copyWith(
                    suffixIcon: dotenv.containsKey(v.env)
                        ? IconButton(
                            tooltip: 'Fill from .env',
                            icon: const Icon(Icons.playlist_add, color: BlazeTheme.accentBright),
                            onPressed: () => ctrls[v.env]?.text = dotenv[v.env] ?? '',
                          )
                        : null,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: !v.editable
                        ? null
                        : () async {
                            await widget.api.setVariable(widget.server.id, v.env, ctrls[v.env]?.text ?? '');
                            if (mounted) await blazeAlert(context, 'Saved ${v.env}');
                          },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        }),
        if (extra.isNotEmpty) const Text('Other keys in .env', style: TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w700)),
        ...extra.map((k) => ListTile(
              title: Text(k, style: const TextStyle(color: BlazeTheme.text)),
              subtitle: Text(dotenv[k] ?? '', style: const TextStyle(color: BlazeTheme.muted, fontFamily: 'monospace')),
            )),
      ],
    );
  }
}

class _Backups extends StatefulWidget {
  const _Backups({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Backups> createState() => _BackupsState();
}

class _BackupsState extends State<_Backups> {
  List<BlazeBackup> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    items = await widget.api.backups(widget.server.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: BlazeBtn(
            label: 'Create backup',
            onTap: () async {
              await widget.api.createBackup(widget.server.id, 'Blaze ${DateTime.now().toIso8601String()}');
              await _load();
            },
          ),
        ),
        Expanded(
          child: ListView(
            children: items
                .map(
                  (b) => ListTile(
                    title: Text(b.name, style: const TextStyle(color: BlazeTheme.text)),
                    subtitle: Text('${b.bytes} B · ${b.completed ? 'ready' : 'running'}', style: const TextStyle(color: BlazeTheme.muted)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () async {
                            await widget.api.restoreBackup(widget.server.id, b.uuid);
                            if (mounted) await blazeAlert(context, 'Restore started.');
                          },
                          child: const Text('Restore'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFFB7185)),
                          onPressed: () async {
                            await widget.api.deleteBackup(widget.server.id, b.uuid);
                            await _load();
                          },
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Dbs extends StatefulWidget {
  const _Dbs({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Dbs> createState() => _DbsState();
}

class _DbsState extends State<_Dbs> {
  List<BlazeDatabase> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    items = await widget.api.databases(widget.server.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: BlazeBtn(
            label: 'Create database',
            onTap: () async {
              final name = await _prompt(context, 'Database name');
              if (name == null || name.isEmpty) return;
              await widget.api.createDatabase(widget.server.id, name);
              await _load();
            },
          ),
        ),
        Expanded(
          child: ListView(
            children: items
                .map(
                  (d) => ListTile(
                    title: Text(d.name, style: const TextStyle(color: BlazeTheme.text)),
                    subtitle: Text('${d.username}@${d.host}:${d.port}', style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: 'mysql://$d'));
                      if (d.password.isNotEmpty) {
                        await Clipboard.setData(ClipboardData(text: d.password));
                        if (mounted) await blazeAlert(context, 'Password copied.');
                      }
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFFB7185)),
                      onPressed: () async {
                        await widget.api.deleteDatabase(widget.server.id, d.id);
                        await _load();
                      },
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Net extends StatefulWidget {
  const _Net({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Net> createState() => _NetState();
}

class _NetState extends State<_Net> {
  List<BlazeAllocation> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    items = await widget.api.allocations(widget.server.id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: items
          .map(
            (a) => ListTile(
              title: Text('${a.ip}:${a.port}', style: const TextStyle(color: BlazeTheme.text)),
              subtitle: Text(a.primary ? 'Primary' : (a.notes.isEmpty ? 'Allocation' : a.notes), style: const TextStyle(color: BlazeTheme.muted)),
              trailing: a.primary
                  ? const Text('PRIMARY', style: TextStyle(color: Color(0xFF5EE9A8), fontWeight: FontWeight.w800, fontSize: 11))
                  : TextButton(
                      onPressed: () async {
                        await widget.api.setPrimary(widget.server.id, a.id);
                        await _load();
                      },
                      child: const Text('Make primary'),
                    ),
            ),
          )
          .toList(),
    );
  }
}

class _Settings extends StatefulWidget {
  const _Settings({required this.server, required this.api});
  final BlazeServer server;
  final BlazeApi api;

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  late final name = TextEditingController(text: widget.server.name);
  late final desc = TextEditingController(text: widget.server.description);
  BlazeSftp? sftp;

  @override
  void initState() {
    super.initState();
    widget.api.sftp(widget.server.id).then((v) {
      if (mounted) setState(() => sftp = v);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    name.dispose();
    desc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: name, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Server name')),
        const SizedBox(height: 10),
        TextField(controller: desc, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField('Description')),
        const SizedBox(height: 10),
        BlazeBtn(
          label: 'Save name',
          onTap: () async {
            await widget.api.rename(widget.server.id, name.text.trim(), desc.text.trim());
            if (mounted) await blazeAlert(context, 'Saved.');
          },
        ),
        const SizedBox(height: 22),
        if (sftp != null)
          Text('SFTP  ${sftp!.ip}:${sftp!.port}\nUser: ${widget.server.id}.sftp.panel', style: const TextStyle(color: BlazeTheme.muted)),
        const SizedBox(height: 22),
        OutlinedButton(
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFFB7185)),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                backgroundColor: BlazeTheme.panel,
                title: const Text('Reinstall?', style: TextStyle(color: BlazeTheme.text)),
                content: const Text('This wipes files and reinstalls the egg.', style: TextStyle(color: BlazeTheme.muted)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reinstall')),
                ],
              ),
            );
            if (ok == true) {
              await widget.api.reinstall(widget.server.id);
              if (mounted) await blazeAlert(context, 'Reinstall started.');
            }
          },
          child: const Text('Reinstall server'),
        ),
      ],
    );
  }
}

Future<String?> _prompt(BuildContext context, String label) async {
  final c = TextEditingController();
  final v = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: BlazeTheme.panel,
      title: Text(label, style: const TextStyle(color: BlazeTheme.text)),
      content: TextField(controller: c, style: const TextStyle(color: BlazeTheme.text), decoration: blazeField(label), autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('OK')),
      ],
    ),
  );
  c.dispose();
  return v;
}
