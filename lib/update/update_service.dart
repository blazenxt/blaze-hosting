import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../compat/os.dart' if (dart.library.io) '../compat/os_io.dart';
import 'installer.dart';
import 'remote_config_source.dart';
import 'update_models.dart';

class UpdateOffer {
  const UpdateOffer({
    required this.current,
    required this.channel,
    required this.force,
    required this.platformName,
  });

  final String current;
  final ChannelUpdate channel;
  final bool force;
  final String platformName;
}

class UpdateService {
  UpdateService({RemoteConfigSource? remote, Installer? installer})
      : _remote = remote ?? RemoteConfigSource(),
        _installer = installer ?? Installer();

  final RemoteConfigSource _remote;
  final Installer _installer;

  RemoteSnapshot? snapshot;
  String currentVersion = '1.0.0';

  Future<void> boot() async {
    final info = await PackageInfo.fromPlatform();
    currentVersion = info.version;
    await _remote.initFirebase();
    snapshot = await _remote.fetch();
  }

  bool get firebaseReady => _remote.firebaseReady;

  ChannelUpdate? get _channel {
    final s = snapshot;
    if (s == null) return null;
    if (kIsWeb) return s.android;
    if (Os.isAndroid) return s.android;
    if (Os.isWindows) return s.windows;
    if (Os.isMacOS) return s.mac;
    if (Os.isLinux) return s.linux;
    if (Os.isIOS) return s.ios;
    return null;
  }

  String get platformName {
    if (kIsWeb) return 'Web';
    if (Os.isAndroid) return 'Android';
    if (Os.isWindows) return 'Windows';
    if (Os.isMacOS) return 'macOS';
    if (Os.isLinux) return 'Linux';
    if (Os.isIOS) return 'iOS';
    return 'this device';
  }

  UpdateOffer? offer() {
    final ch = _channel;
    if (ch == null) return null;
    final force = VersionUtil.belowMin(currentVersion, ch.minVersion);
    final newer = VersionUtil.isNewer(currentVersion, ch.latest);
    if (!force && !newer) return null;
    if (!ch.hasUrl) return null;
    return UpdateOffer(
      current: currentVersion,
      channel: ch,
      force: force,
      platformName: platformName,
    );
  }

  Future<void> apply(UpdateOffer offer, ProgressFn onProgress) {
    return _installer.install(url: offer.channel.url, onProgress: onProgress);
  }
}
