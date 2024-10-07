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
