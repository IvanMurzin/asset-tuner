class EntitlementsDto {
  const EntitlementsDto({
    this.maxAccounts,
    this.maxSubaccounts,
    this.fiatLimit,
    this.cryptoLimit,
  });

  final int? maxAccounts;
  final int? maxSubaccounts;
  final int? fiatLimit;
  final int? cryptoLimit;

  factory EntitlementsDto.fromJson(Map<String, dynamic> json) {
    int? asInt(String key) {
      final raw = json[key];
      return raw is num ? raw.toInt() : null;
    }

    return EntitlementsDto(
      maxAccounts: asInt('max_accounts'),
      maxSubaccounts: asInt('max_subaccounts'),
      fiatLimit: asInt('fiat_limit'),
      cryptoLimit: asInt('crypto_limit'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'max_accounts': maxAccounts,
      'max_subaccounts': maxSubaccounts,
      'fiat_limit': fiatLimit,
      'crypto_limit': cryptoLimit,
    };
  }
}
