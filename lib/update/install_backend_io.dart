import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'installer.dart';

const _android = MethodChannel('com.blazenxt.hosting/install');

Future<void> runNativeInstall({
  required String url,
  required ProgressFn onProgress,
}) async {
  if (Platform.isAndroid) {
    await _androidApk(url, onProgress);
    return;
  }
  if (Platform.isWindows) {
    await _windowsSilent(url, onProgress);
    return;
  }
  if (Platform.isMacOS) {
    await _macPkg(url, onProgress);
    return;
  }
  if (Platform.isLinux) {
    await _linuxPackage(url, onProgress);
    return;
  }
  if (Platform.isIOS) {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return;
  }
  throw UnsupportedError('In-app install is not available on this OS');
}

Future<File> _download(String url, String filename, ProgressFn onProgress) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  if (await file.exists()) {
    await file.delete();
  }
  await Dio().download(
    url,
    file.path,
    onReceiveProgress: onProgress,
    options: Options(
      followRedirects: true,
      receiveTimeout: const Duration(minutes: 10),
    ),
  );
  return file;
}

Future<void> _androidApk(String url, ProgressFn onProgress) async {
  final file = await _download(url, 'blaze-hosting.apk', onProgress);
  var can = false;
  try {
    can = await _android.invokeMethod<bool>('canInstall') ?? false;
  } on MissingPluginException {
    can = true;
  }
  if (!can) {
    await _android.invokeMethod('openInstallPermission');
    throw StateError('Allow Blaze Hosting to install updates, then tap Update again.');
  }
  await _android.invokeMethod('installApk', {'path': file.path});
}

Future<void> _windowsSilent(String url, ProgressFn onProgress) async {
  final file = await _download(url, 'blaze-hosting-setup.exe', onProgress);
  final result = await Process.start(
    file.path,
    const ['/VERYSILENT', '/NORESTART', '/CLOSEAPPLICATIONS', '/RESTARTAPPLICATIONS'],
    mode: ProcessStartMode.detached,
  );
  await result.exitCode.timeout(const Duration(seconds: 2), onTimeout: () => 0);
}

Future<void> _macPkg(String url, ProgressFn onProgress) async {
  final file = await _download(url, 'blaze-hosting.pkg', onProgress);
  await Process.start('open', [file.path], mode: ProcessStartMode.detached);
}

Future<void> _linuxPackage(String url, ProgressFn onProgress) async {
  final lower = url.toLowerCase();
  if (lower.endsWith('.appimage')) {
    final file = await _download(url, 'blaze-hosting.AppImage', onProgress);
    await Process.run('chmod', ['+x', file.path]);
    await Process.start(file.path, const [], mode: ProcessStartMode.detached);
    return;
  }
  if (lower.endsWith('.deb')) {
    final file = await _download(url, 'blaze-hosting.deb', onProgress);
    final r = await Process.run('pkexec', ['dpkg', '-i', file.path]);
    if (r.exitCode != 0) {
      throw StateError(
        (r.stderr as String?)?.isNotEmpty == true ? r.stderr as String : 'dpkg failed',
      );
    }
    return;
  }
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
