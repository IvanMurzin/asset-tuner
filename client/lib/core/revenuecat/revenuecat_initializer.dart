import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:asset_tuner/core/config/app_config.dart';
import 'package:asset_tuner/core/logger/logger.dart';

abstract final class RevenueCatInitializer {
  static Future<void> init() async {
    final config = AppConfig.instance;
    final debug = config.env.toLowerCase() == 'dev';
    if (debug) {
      await Purchases.setLogLevel(LogLevel.debug);
    }
    final purchasesConfig = PurchasesConfiguration(config.revenueCatApiKey);
    await Purchases.configure(purchasesConfig);
    logger.i('revenuecat_configured');
  }
}
