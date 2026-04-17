import 'package:asset_tuner/domain/account/entity/account_entity.dart';
import 'package:asset_tuner/domain/asset/entity/asset_entity.dart';

enum AddSubaccountCopyProfile { bank, walletExchange, cash, other }

enum AddSubaccountPreferredAssetKind { fiat, crypto }

class AddSubaccountContext {
  const AddSubaccountContext({required this.copyProfile, required this.preferredAssetKind});

  final AddSubaccountCopyProfile copyProfile;
  final AddSubaccountPreferredAssetKind preferredAssetKind;

  factory AddSubaccountContext.fromAccountType(AccountType? type) {
    return switch (type) {
      AccountType.bank => const AddSubaccountContext(
        copyProfile: AddSubaccountCopyProfile.bank,
        preferredAssetKind: AddSubaccountPreferredAssetKind.fiat,
      ),
      AccountType.wallet || AccountType.exchange => const AddSubaccountContext(
        copyProfile: AddSubaccountCopyProfile.walletExchange,
        preferredAssetKind: AddSubaccountPreferredAssetKind.crypto,
      ),
      AccountType.cash => const AddSubaccountContext(
        copyProfile: AddSubaccountCopyProfile.cash,
        preferredAssetKind: AddSubaccountPreferredAssetKind.fiat,
      ),
      AccountType.other || null => const AddSubaccountContext(
        copyProfile: AddSubaccountCopyProfile.other,
        preferredAssetKind: AddSubaccountPreferredAssetKind.fiat,
      ),
    };
  }

  AssetEntity? resolveDefaultAsset({
    required List<AssetEntity> fiatAssets,
    required List<AssetEntity> cryptoAssets,
  }) {
    final preferred = preferredAssetKind == AddSubaccountPreferredAssetKind.fiat
        ? fiatAssets
        : cryptoAssets;
    final preferredUnlocked = _firstUnlocked(preferred);
    if (preferredUnlocked != null) {
      return preferredUnlocked;
    }

    final fallback = preferredAssetKind == AddSubaccountPreferredAssetKind.fiat
        ? cryptoAssets
        : fiatAssets;
    return _firstUnlocked(fallback);
  }

  AssetEntity? _firstUnlocked(List<AssetEntity> assets) {
    for (final asset in assets) {
      if (!(asset.isLocked ?? false)) {
        return asset;
      }
    }
    return null;
  }
}
