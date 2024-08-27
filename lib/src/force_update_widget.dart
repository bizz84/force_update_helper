import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'force_update_client.dart';

class ForceUpdateWidget extends StatefulWidget {
  const ForceUpdateWidget({
    super.key,
    required this.child,
    this.navigatorKey,
    required this.forceUpdateClient,
    required this.allowCancel,
    required this.showForceUpdateAlert,
    required this.showStoreListing,
    this.onException,
  });
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;
  final ForceUpdateClient forceUpdateClient;
  final bool allowCancel;
  final Future<bool?> Function(BuildContext context, bool allowCancel)
      showForceUpdateAlert;
  final Future<void> Function(Uri storeUrl) showStoreListing;
  final void Function(Object error, StackTrace? stackTrace)? onException;

  @override
  State<ForceUpdateWidget> createState() => _ForceUpdateWidgetState();
}

class _ForceUpdateWidgetState extends State<ForceUpdateWidget>
    with WidgetsBindingObserver {
  var _isAlertVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkIfAppUpdateIsNeeded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfAppUpdateIsNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkIfAppUpdateIsNeeded() async {
    if (_isAlertVisible) {
      return;
    }
    try {
      final storeUrl = await widget.forceUpdateClient.storeUrl();
      if (storeUrl == null) {
        return;
      }
      final updateRequired =
          await widget.forceUpdateClient.isAppUpdateRequired();
      if (updateRequired) {
        return await _triggerForceUpdate(Uri.parse(storeUrl));
      }
    } catch (e, st) {
      final handler = widget.onException;
      if (handler != null) {
        handler.call(e, st);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _triggerForceUpdate(Uri storeUrl) async {
    final ctx = widget.navigatorKey?.currentContext ?? context;
    // * setState not needed, just keeping track of alert visibility
    _isAlertVisible = true;
    final success = await widget.showForceUpdateAlert(ctx, widget.allowCancel);
    // * setState not needed, just keeping track of alert visibility
    _isAlertVisible = false;
    if (success == true) {
      // * open app store page
      await widget.showStoreListing(storeUrl);
    } else if (success == false) {
      // * user clicked on the cancel button
    } else if (success == null && widget.allowCancel == false) {
      // * user clicked on the Android back button: show alert again
      return _triggerForceUpdate(storeUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ignore_for_file: use_build_context_synchronously
