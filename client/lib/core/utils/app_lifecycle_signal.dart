import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// App lifecycle changes as a stream, for code outside the widget tree.
@lazySingleton
class AppLifecycleSignal {
  AppLifecycleSignal() : _controller = StreamController<AppLifecycleState>.broadcast() {
    _listener = AppLifecycleListener(onStateChange: _controller.add);
  }

  @visibleForTesting
  AppLifecycleSignal.fromController(this._controller);

  final StreamController<AppLifecycleState> _controller;
  AppLifecycleListener? _listener;

  Stream<AppLifecycleState> get changes => _controller.stream;

  @disposeMethod
  Future<void> dispose() async {
    _listener?.dispose();
    await _controller.close();
  }
}
