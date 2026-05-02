import 'dart:async';

import 'package:injectable/injectable.dart';

/// One-way channel signalling "backend reported our token is invalid".
///
/// Inverts the dependency between the data layer and presentation:
/// - the data layer ([SupabaseFailureMapper] and friends) emits an event via
///   [notifyUnauthorized] whenever it sees a 401,
/// - the presentation layer ([AuthCubit]) subscribes to [stream] and, on
///   each event, drops the session to `unauthenticated`. The router then
///   handles the redirect to `/sign-in` on its own.
///
/// Events carry no payload — this is purely a "token is dead" signal. From
/// here, the only sign-out path goes through [AuthCubit].
@lazySingleton
class UnauthorizedNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get stream => _controller.stream;

  void notifyUnauthorized() {
    if (_controller.isClosed) return;
    _controller.add(null);
  }

  @disposeMethod
  Future<void> dispose() => _controller.close();
}
