import 'dart:ui';

import 'package:injectable/injectable.dart';

abstract interface class ISystemLocaleProvider {
  Locale getCurrentLocale();
}

@LazySingleton(as: ISystemLocaleProvider)
class SystemLocaleProvider implements ISystemLocaleProvider {
  @override
  Locale getCurrentLocale() {
    return PlatformDispatcher.instance.locale;
  }
}
