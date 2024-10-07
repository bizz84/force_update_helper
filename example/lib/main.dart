import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:force_update_example/src/remote_config_gist_client.dart';
import 'package:force_update_example/src/show_alert_dialog.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      builder: (context, child) {
        return ForceUpdateWidget(
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
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
