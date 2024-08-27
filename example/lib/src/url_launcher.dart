import 'dart:developer';

import 'package:url_launcher/url_launcher.dart';

/// A simple wrapper for the url_launcher package
class UrlLauncher {
  const UrlLauncher();

  static const _name = 'URL Launcher';

  Future<bool> launch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        log('Launching URL: $uri', name: _name);
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } else {
        log('Cannot launch URL: $uri', name: _name);
        return false;
      }
    } catch (e, st) {
      log('Failed launching URL: $uri, $e',
          name: _name, error: e, stackTrace: st);
      return false;
    }
  }
}
