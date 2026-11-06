import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'update_models.dart';

class RemoteConfigSource {
  RemoteConfigSource();

  bool firebaseReady = false;

  Future<void> initFirebase() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      firebaseReady = true;
    } catch (e, st) {
      firebaseReady = false;
      debugPrint('Firebase init skipped: $e\n$st');
    }
  }

  Future<RemoteSnapshot> fetch() async {
    if (!firebaseReady) {
      throw StateError('Firebase is not configured');
    }

    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 12),
        minimumFetchInterval: kReleaseMode
            ? const Duration(minutes: 15)
            : Duration.zero,
      ),
    );
    await rc.setDefaults(_defaults);
    await rc.fetchAndActivate();

    ChannelUpdate ch(String verKey, String urlKey, String minKey, String notesKey) {
      return ChannelUpdate(
        latest: rc.getString(verKey),
        url: rc.getString(urlKey),
        minVersion: rc.getString(minKey),
        notes: rc.getString(notesKey),
      );
    }

    return RemoteSnapshot(
      panelUrl: rc.getString('panel_url'),
      maintenance: rc.getString('maintenance_message'),
      android: ch(
        'latest_android_version',
        'android_url',
        'min_android_version',
        'android_notes',
      ),
      windows: ch(
        'latest_windows_version',
        'windows_url',
        'min_windows_version',
        'windows_notes',
      ),
      mac: ch(
        'latest_mac_version',
        'mac_url',
        'min_mac_version',
        'mac_notes',
      ),
      linux: ch(
        'latest_linux_version',
        'linux_url',
        'min_linux_version',
        'linux_notes',
      ),
      ios: ch(
        'latest_ios_version',
        'ios_url',
        'min_ios_version',
        'ios_notes',
      ),
      fromFirebase: true,
    );
  }

  static const _defaults = <String, dynamic>{
    'panel_url': 'https://panel.nawazfx.com',
    'maintenance_message': '',
    'latest_android_version': '1.0.0',
    'android_url': 'https://nawazfx.com/app/blaze-hosting.apk',
    'min_android_version': '',
    'android_notes': '',
    'latest_windows_version': '1.0.0',
    'windows_url': 'https://nawazfx.com/app/blaze-hosting-setup.exe',
    'min_windows_version': '',
    'windows_notes': '',
    'latest_mac_version': '1.0.0',
    'mac_url': 'https://nawazfx.com/app/blaze-hosting.pkg',
    'min_mac_version': '',
    'mac_notes': '',
    'latest_linux_version': '1.0.0',
    'linux_url': 'https://nawazfx.com/app/blaze-hosting.AppImage',
    'min_linux_version': '',
    'linux_notes': '',
    'latest_ios_version': '1.0.0',
    'ios_url': 'https://nawazfx.com/app',
    'min_ios_version': '',
    'ios_notes': '',
  };
}
