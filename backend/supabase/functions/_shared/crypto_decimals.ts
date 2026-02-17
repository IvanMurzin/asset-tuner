const CRYPTO_DECIMALS_OVERRIDES: Record<string, number> = {
  bitcoin: 8,
  ethereum: 18,
  tether: 6,
  'binancecoin': 18,
  solana: 9,
  ripple: 6,
  'usd-coin': 6,
  cardano: 6,
  dogecoin: 8,
  tron: 6,
  steth: 18,
  'wrapped-bitcoin': 8,
  chainlink: 18,
  avalanche: 9,
  'avalanche-2': 9,
  litecoin: 8,
  'bitcoin-cash': 8,
  polkadot: 10,
  'near': 24,
  'matic-network': 18,
  toncoin: 9,
  'the-open-network': 9,
};

export function cryptoDecimalsForCoinGeckoId(id: string): number {
  return CRYPTO_DECIMALS_OVERRIDES[id] ?? 8;
}
