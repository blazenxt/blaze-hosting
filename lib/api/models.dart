class BlazeServer {
  const BlazeServer({
    required this.id,
    required this.uuid,
    required this.name,
    required this.node,
    required this.memoryMb,
    required this.diskMb,
    required this.description,
  });

  final String id;
  final String uuid;
  final String name;
  final String node;
  final int memoryMb;
  final int diskMb;
  final String description;

  factory BlazeServer.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    final limits = (a['limits'] as Map?)?.cast<String, dynamic>() ?? {};
    return BlazeServer(
      id: '${a['identifier'] ?? ''}',
      uuid: '${a['uuid'] ?? ''}',
      name: '${a['name'] ?? 'Server'}',
      node: '${a['node'] ?? ''}',
      memoryMb: int.tryParse('${limits['memory'] ?? 0}') ?? 0,
      diskMb: int.tryParse('${limits['disk'] ?? 0}') ?? 0,
      description: '${a['description'] ?? ''}',
    );
  }
}

class BlazeResources {
  const BlazeResources({required this.state, required this.memoryBytes, required this.cpu});

  final String state;
  final int memoryBytes;
  final double cpu;
}

class BlazeFile {
  const BlazeFile({required this.name, required this.size, required this.isFile, required this.modified});

  final String name;
  final int size;
  final bool isFile;
  final String modified;

  factory BlazeFile.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    return BlazeFile(
      name: '${a['name'] ?? ''}',
      size: int.tryParse('${a['size'] ?? 0}') ?? 0,
      isFile: a['is_file'] == true,
      modified: '${a['modified_at'] ?? ''}',
    );
  }
}

class BlazeVariable {
  const BlazeVariable({
    required this.name,
    required this.description,
    required this.env,
    required this.value,
    required this.editable,
    required this.rules,
  });

  final String name;
  final String description;
  final String env;
  final String value;
  final bool editable;
  final String rules;

  factory BlazeVariable.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    return BlazeVariable(
      name: '${a['name'] ?? a['env_variable'] ?? ''}',
      description: '${a['description'] ?? ''}',
      env: '${a['env_variable'] ?? ''}',
      value: '${a['server_value'] ?? a['default_value'] ?? ''}',
      editable: a['is_editable'] != false,
      rules: '${a['rules'] ?? ''}',
    );
  }
}

class BlazeBackup {
  const BlazeBackup({
    required this.uuid,
    required this.name,
    required this.bytes,
    required this.completed,
    required this.locked,
  });

  final String uuid;
  final String name;
  final int bytes;
  final bool completed;
  final bool locked;

  factory BlazeBackup.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    return BlazeBackup(
      uuid: '${a['uuid'] ?? ''}',
      name: '${a['name'] ?? 'Backup'}',
      bytes: int.tryParse('${a['bytes'] ?? 0}') ?? 0,
      completed: a['completed_at'] != null,
      locked: a['is_locked'] == true,
    );
  }
}

class BlazeDatabase {
  const BlazeDatabase({
    required this.id,
    required this.name,
    required this.username,
    required this.host,
    required this.port,
    required this.password,
  });

  final String id;
  final String name;
  final String username;
  final String host;
  final String port;
  final String password;

  factory BlazeDatabase.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    final host = (a['host'] as Map?)?.cast<String, dynamic>() ?? {};
    final rel = (json['attributes'] is Map ? (json['attributes'] as Map)['relationships'] : null) as Map?;
    final pw = (((rel?['password'] as Map?)?['attributes'] as Map?)?['password']) ?? a['password'] ?? '';
    return BlazeDatabase(
      id: '${a['id'] ?? ''}',
      name: '${a['name'] ?? ''}',
      username: '${a['username'] ?? ''}',
      host: '${host['address'] ?? ''}',
      port: '${host['port'] ?? ''}',
      password: '$pw',
    );
  }
}

class BlazeAllocation {
  const BlazeAllocation({
    required this.id,
    required this.ip,
    required this.port,
    required this.notes,
    required this.primary,
  });

  final int id;
  final String ip;
  final int port;
  final String notes;
  final bool primary;

  factory BlazeAllocation.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    return BlazeAllocation(
      id: int.tryParse('${a['id'] ?? 0}') ?? 0,
      ip: '${a['ip'] ?? ''}',
      port: int.tryParse('${a['port'] ?? 0}') ?? 0,
      notes: '${a['notes'] ?? ''}',
      primary: a['is_default'] == true,
    );
  }
}

class BlazeAccount {
  const BlazeAccount({required this.id, required this.email, required this.username, required this.name});

  final String id;
  final String email;
  final String username;
  final String name;

  factory BlazeAccount.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    return BlazeAccount(
      id: '${a['id'] ?? ''}',
      email: '${a['email'] ?? ''}',
      username: '${a['username'] ?? ''}',
      name: '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}'.trim(),
    );
  }
}

class BlazeApiKey {
  const BlazeApiKey({required this.identifier, required this.description, this.token});

  final String identifier;
  final String description;
  final String? token;

  factory BlazeApiKey.fromJson(Map<String, dynamic> json) {
    final a = (json['attributes'] as Map?)?.cast<String, dynamic>() ?? json;
    return BlazeApiKey(
      identifier: '${a['identifier'] ?? ''}',
      description: '${a['description'] ?? ''}',
      token: a['token']?.toString(),
    );
  }
}

class BlazeSftp {
  const BlazeSftp({required this.ip, required this.port});
  final String ip;
  final int port;
}

Map<String, String> parseEnv(String raw) {
  final out = <String, String>{};
  for (final line in raw.split(RegExp(r'\r?\n'))) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final i = t.indexOf('=');
    if (i <= 0) continue;
    var k = t.substring(0, i).trim();
    var v = t.substring(i + 1).trim();
    if (k.startsWith('export ')) k = k.substring(7).trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
      v = v.substring(1, v.length - 1);
    }
    out[k] = v;
  }
  return out;
}
