import 'package:flutter/widgets.dart';

class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({
    super.key,
    required this.child,
    this.onResumed,
    this.onInactive,
    this.onPaused,
    this.onDetached,
    this.onHidden,
    this.onStateChanged,
  });

  final Widget child;
  final VoidCallback? onResumed;
  final VoidCallback? onInactive;
  final VoidCallback? onPaused;
  final VoidCallback? onDetached;
  final VoidCallback? onHidden;
  final ValueChanged<AppLifecycleState>? onStateChanged;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.onStateChanged?.call(state);
    switch (state) {
      case AppLifecycleState.resumed:
        widget.onResumed?.call();
      case AppLifecycleState.inactive:
        widget.onInactive?.call();
      case AppLifecycleState.paused:
        widget.onPaused?.call();
      case AppLifecycleState.detached:
        widget.onDetached?.call();
      case AppLifecycleState.hidden:
        widget.onHidden?.call();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
