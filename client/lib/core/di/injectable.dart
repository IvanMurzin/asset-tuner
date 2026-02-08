import 'package:injectable/injectable.dart';

import 'get_it.dart';
import 'injectable.config.dart';

@InjectableInit()
void initDependencies() => getIt.init();
