class EntitlementsEntity {
  const EntitlementsEntity({
    this.maxAccounts,
    this.maxSubaccounts,
    int? fiatLimit,
    int? cryptoLimit,
    bool? anyBaseCurrency,
    Set<String>? freeBaseCurrencyCodes,
  }) : fiatLimit = fiatLimit ?? (anyBaseCurrency == true ? null : 5),
       cryptoLimit = cryptoLimit ?? (anyBaseCurrency == true ? null : 5),
       freeBaseCurrencyCodes = freeBaseCurrencyCodes ?? const <String>{};

  final int? maxAccounts;
  final int? maxSubaccounts;
  final int? fiatLimit;
  final int? cryptoLimit;
  final Set<String> freeBaseCurrencyCodes;

  // Backward-compatible view for existing presentation logic.
  bool get anyBaseCurrency => fiatLimit == null;

  EntitlementsEntity copyWith({
    int? maxAccounts,
    int? maxSubaccounts,
    int? fiatLimit,
    int? cryptoLimit,
    Set<String>? freeBaseCurrencyCodes,
  }) {
    return EntitlementsEntity(
      maxAccounts: maxAccounts ?? this.maxAccounts,
      maxSubaccounts: maxSubaccounts ?? this.maxSubaccounts,
      fiatLimit: fiatLimit ?? this.fiatLimit,
      cryptoLimit: cryptoLimit ?? this.cryptoLimit,
      freeBaseCurrencyCodes:
          freeBaseCurrencyCodes ?? this.freeBaseCurrencyCodes,
    );
  }
}
