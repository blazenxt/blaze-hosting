class ChannelUpdate {
  const ChannelUpdate({
    required this.latest,
    required this.url,
    this.minVersion,
    this.notes,
  });

  final String latest;
  final String url;
  final String? minVersion;
  final String? notes;

  bool get hasUrl => url.startsWith('https://');
}

class RemoteSnapshot {
  const RemoteSnapshot({
    required this.panelUrl,
    required this.maintenance,
    required this.android,
    required this.windows,
    required this.mac,
    required this.linux,
    required this.ios,
    required this.fromFirebase,
  });

  final String panelUrl;
  final String maintenance;
  final ChannelUpdate android;
  final ChannelUpdate windows;
  final ChannelUpdate mac;
  final ChannelUpdate linux;
  final ChannelUpdate ios;
  final bool fromFirebase;
}

class VersionUtil {
  /// Returns true when [remote] is strictly newer than [local].
  static bool isNewer(String local, String remote) {
    List<int> parts(String v) {
      final core = v.split('+').first.split('-').first.trim();
      return core.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    }

    final a = parts(local);
    final b = parts(remote);
    final n = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < n; i++) {
      final x = i < a.length ? a[i] : 0;
      final y = i < b.length ? b[i] : 0;
      if (y > x) return true;
      if (y < x) return false;
    }
    return false;
  }

  static bool belowMin(String local, String? min) {
    if (min == null || min.isEmpty) return false;
    return isNewer(local, min);
  }
}
