import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';
import 'package:asset_tuner/presentation/account/page/add_subaccount_context.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddSubaccountContext', () {
    test('maps account types to copy profile and preferred asset kind', () {
      final bank = AddSubaccountContext.fromAccountType(AccountType.bank);
      final wallet = AddSubaccountContext.fromAccountType(AccountType.wallet);
      final exchange = AddSubaccountContext.fromAccountType(AccountType.exchange);
      final cash = AddSubaccountContext.fromAccountType(AccountType.cash);
      final other = AddSubaccountContext.fromAccountType(AccountType.other);
      final fallback = AddSubaccountContext.fromAccountType(null);

      expect(bank.copyProfile, AddSubaccountCopyProfile.bank);
      expect(bank.preferredAssetKind, AddSubaccountPreferredAssetKind.fiat);

      expect(wallet.copyProfile, AddSubaccountCopyProfile.walletExchange);
      expect(wallet.preferredAssetKind, AddSubaccountPreferredAssetKind.crypto);

      expect(exchange.copyProfile, AddSubaccountCopyProfile.walletExchange);
      expect(exchange.preferredAssetKind, AddSubaccountPreferredAssetKind.crypto);

      expect(cash.copyProfile, AddSubaccountCopyProfile.cash);
      expect(cash.preferredAssetKind, AddSubaccountPreferredAssetKind.fiat);

      expect(other.copyProfile, AddSubaccountCopyProfile.other);
      expect(other.preferredAssetKind, AddSubaccountPreferredAssetKind.fiat);

      expect(fallback.copyProfile, AddSubaccountCopyProfile.other);
      expect(fallback.preferredAssetKind, AddSubaccountPreferredAssetKind.fiat);
    });

    test('resolves unlocked asset from preferred kind first', () {
      final context = AddSubaccountContext.fromAccountType(AccountType.wallet);
      final selected = context.resolveDefaultAsset(
        fiatAssets: [_asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar')],
        cryptoAssets: [
          _asset(id: 'crypto-btc', kind: AssetKind.crypto, code: 'BTC', name: 'Bitcoin'),
          _asset(id: 'crypto-eth', kind: AssetKind.crypto, code: 'ETH', name: 'Ethereum'),
        ],
      );

      expect(selected?.code, 'BTC');
    });

    test('falls back to opposite kind when preferred assets are locked', () {
      final context = AddSubaccountContext.fromAccountType(AccountType.wallet);
      final selected = context.resolveDefaultAsset(
        fiatAssets: [_asset(id: 'fiat-usd', kind: AssetKind.fiat, code: 'USD', name: 'US Dollar')],
        cryptoAssets: [
          _asset(
            id: 'crypto-btc',
            kind: AssetKind.crypto,
            code: 'BTC',
            name: 'Bitcoin',
            isLocked: true,
          ),
        ],
      );

      expect(selected?.code, 'USD');
    });

    test('returns null when all available assets are locked', () {
      final context = AddSubaccountContext.fromAccountType(AccountType.bank);
      final selected = context.resolveDefaultAsset(
        fiatAssets: [
          _asset(
            id: 'fiat-usd',
            kind: AssetKind.fiat,
            code: 'USD',
            name: 'US Dollar',
            isLocked: true,
          ),
        ],
        cryptoAssets: [
          _asset(
            id: 'crypto-btc',
            kind: AssetKind.crypto,
            code: 'BTC',
            name: 'Bitcoin',
            isLocked: true,
          ),
        ],
      );

      expect(selected, isNull);
    });
  });
}

AssetEntity _asset({
  required String id,
  required AssetKind kind,
  required String code,
  required String name,
  bool isLocked = false,
}) {
  return AssetEntity(
    id: id,
    kind: kind,
    code: code,
    name: name,
    provider: '',
    providerRef: '',
    rank: 1,
    decimals: 2,
    isActive: true,
    isLocked: isLocked,
  );
}
