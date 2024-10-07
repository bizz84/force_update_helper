# Example: fetching a remote config JSON from a GitHub Gist

This example app shows how to fetch some remote config JSON from a `RemoteConfigGistClient`:

```dart
ForceUpdateWidget(
  navigatorKey: _rootNavigatorKey,
  forceUpdateClient: ForceUpdateClient(
    fetchRequiredVersion: () async {
      // * Fetch remote config from an API endpoint.
      // * Alternatively, you can use Firebase Remote Config
      final client = RemoteConfigGistClient(dio: Dio());
      final remoteConfig = await client.fetchRemoteConfig();
      return remoteConfig.requiredVersion;
    },
    // * Example ID from this app: https://fluttertips.dev/
    // * To avoid mistakes, store the ID as an environment variable and
    // * read it with String.fromEnvironment
    iosAppStoreId: '6482293361',
  ),
  allowCancel: false,
  showForceUpdateAlert: (context, allowCancel) => showAlertDialog(
    context: context,
    title: 'App Update Required',
    content: 'Please update to continue using the app.',
    cancelActionText: allowCancel ? 'Later' : null,
    defaultActionText: 'Update Now',
  ),
  showStoreListing: (storeUrl) async {
    if (await canLaunchUrl(storeUrl)) {
      await launchUrl(
        storeUrl,
        // * Open app store app directly (or fallback to browser)
        mode: LaunchMode.externalApplication,
      );
    } else {
      log('Cannot launch URL: $storeUrl');
    }
  },
  onException: (e, st) {
    log(e.toString());
  },
  child: child!,
)
```

The `RemoteConfigGistData` class can be used to fetch and parse some JSON in this format:

```json
{
  "config" : {
    "required_version": "2.0.0"
  }
}
```

Here's the reference `RemoteConfigGistData` class:

```dart
import 'dart:convert';

import 'package:dio/dio.dart';

class RemoteConfigGistData {
  RemoteConfigGistData({required this.requiredVersion});
  final String requiredVersion;

  factory RemoteConfigGistData.fromJson(Map<String, dynamic> json) {
    final requiredVersion = json['config']?['required_version'];
    if (requiredVersion == null) {
      throw FormatException('required_version not found in JSON: $json');
    }
    return RemoteConfigGistData(requiredVersion: requiredVersion);
  }
}

/// An API client class for fetching a remote config JSON from a GitHub gist
class RemoteConfigGistClient {
  const RemoteConfigGistClient({required this.dio});
  final Dio dio;

  /// Fetch the remote config JSON
  Future<RemoteConfigGistData> fetchRemoteConfig() async {
    // TODO: Update this with your GitHub username
    const owner = 'bizz84';
    // TODO: Update this with your gist IDs
    const gistId = 'e5b8041b35c58a3eba2baa23096d1678';
    // TODO: Update this with your gist file name
    const fileName = 'app_name_remote_config.json';
    const url =
        'https://gist.githubusercontent.com/$owner/$gistId/raw/$fileName';
    final response = await dio.get(url);
    final jsonData = jsonDecode(response.data);
    return RemoteConfigGistData.fromJson(jsonData);
  }
}
```
