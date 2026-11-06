import 'package:url_launcher/url_launcher.dart';

import 'installer.dart';

Future<void> runNativeInstall({
  required String url,
  required ProgressFn onProgress,
}) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }
  throw UnsupportedError('In-app install is not available on web');
}
