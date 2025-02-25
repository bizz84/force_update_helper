import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// Client used to check if a force upgrade is needed
class ForceUpdateClient {
  const ForceUpdateClient({
    required this.fetchRequiredVersion,
    this.fetchCurrentPatchVersion,
    required this.iosAppStoreId,
  });

  /// Fetch the required version from the remote
  final Future<String> Function() fetchRequiredVersion;

  /// Optional callback to fetch the current patch version from code push solutions like Shorebird
  final Future<String> Function()? fetchCurrentPatchVersion;

  /// The app store ID for the iOS app
  final String iosAppStoreId;

  static const _name = 'Force Update';

  /// Fetches the required version and checks if a force update is needed by
  /// comparing it with the current version (from PackageInfo)
  Future<bool> isAppUpdateRequired() async {
    // * Only force app update on iOS & Android
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    final requiredVersionStr = await fetchRequiredVersion();
    if (requiredVersionStr.isEmpty) {
      log('Remote Config: required_version not set. Ignoring.', name: _name);
      return false;
    }
    final patchVersion = await fetchCurrentPatchVersion?.call();
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = patchVersion ?? packageInfo.version;

    // * On Android, the current version may appear as `^X.Y.Z(.*)`
    // * But semver can only parse this if it's formatted as `^X.Y.Z-(.*)`
    // * and we only care about X.Y.Z, so we can remove the flavor
    final currentVersionStr =
        RegExp(r'\d+\.\d+\.\d+').matchAsPrefix(currentVersion)!.group(0)!;

    // * Parse versions in semver format
    final parsedRequiredVersion = Version.parse(requiredVersionStr);
    final parsedCurrentVersion = Version.parse(currentVersionStr);

    final updateRequired = parsedCurrentVersion < parsedRequiredVersion;
    log(
        'Update ${updateRequired ? '' : 'not '}required. '
        'Current version: $parsedCurrentVersion, required version: $parsedRequiredVersion',
        name: _name);
    return updateRequired;
  }

  /// Returns the download URL for each store depending on the platform
  Future<String?> storeUrl() async {
    if (kIsWeb) {
      return null;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // * On iOS, use the given app ID
      return iosAppStoreId.isNotEmpty
          ? 'https://apps.apple.com/app/id$iosAppStoreId'
          : null;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final packageInfo = await PackageInfo.fromPlatform();
      // * On Android, use the package name from PackageInfo
      return 'https://play.google.com/store/apps/details?id=${packageInfo.packageName}';
    } else {
      log('No store URL for platform: ${defaultTargetPlatform.name}',
          name: _name);
      return null;
    }
  }
}
