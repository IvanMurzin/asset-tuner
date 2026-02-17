export const USD_PRICE_DECIMALS = 12;

const ATOMIC_RE = /^-?\d+$/;
const pow10Cache = new Map<number, bigint>([[0, 1n]]);

export function isAtomicString(value: string): boolean {
  return ATOMIC_RE.test(value);
}

export function assertAtomicString(value: string, field: string): void {
  if (!isAtomicString(value)) {
    throw new Error(`Invalid atomic string: ${field}`);
  }
}

export function assertDecimals(decimals: number, field: string): void {
  if (!Number.isInteger(decimals) || decimals < 0 || decimals > 18) {
    throw new Error(`Invalid decimals (${field}). Expected 0..18`);
  }
}

function pow10(decimals: number): bigint {
  const cached = pow10Cache.get(decimals);
  if (cached !== undefined) {
    return cached;
  }

  let value = 1n;
  for (let i = 0; i < decimals; i += 1) {
    value *= 10n;
  }
  pow10Cache.set(decimals, value);
  return value;
}

function divRoundHalfAwayFromZero(numerator: bigint, denominator: bigint): bigint {
  if (denominator <= 0n) {
    throw new Error('Denominator must be greater than zero');
  }

  const negative = numerator < 0n;
  const absNumerator = negative ? -numerator : numerator;

  let q = absNumerator / denominator;
  const r = absNumerator % denominator;

  if (r * 2n >= denominator) {
    q += 1n;
  }

  return negative ? -q : q;
}

export function atomicMulPriceToUsdAtomic(
  amountAtomic: string,
  amountDecimals: number,
  usdPriceAtomic: string,
  usdPriceDecimals: number,
  usdTargetDecimals = USD_PRICE_DECIMALS,
): string {
  assertAtomicString(amountAtomic, 'amountAtomic');
  assertAtomicString(usdPriceAtomic, 'usdPriceAtomic');
  assertDecimals(amountDecimals, 'amountDecimals');
  assertDecimals(usdPriceDecimals, 'usdPriceDecimals');
  assertDecimals(usdTargetDecimals, 'usdTargetDecimals');

  const amount = BigInt(amountAtomic);
  const price = BigInt(usdPriceAtomic);
  const product = amount * price;

  const scaleExp = amountDecimals + usdPriceDecimals - usdTargetDecimals;
  if (scaleExp === 0) {
    return product.toString();
  }
  if (scaleExp > 0) {
    return divRoundHalfAwayFromZero(product, pow10(scaleExp)).toString();
  }
  return (product * pow10(-scaleExp)).toString();
}

export function convertUsdAtomicToBaseAtomic(
  totalUsdAtomic: string,
  usdDecimals: number,
  baseUsdPriceAtomic: string,
  baseUsdPriceDecimals: number,
  baseDecimals: number,
): string | null {
  assertAtomicString(totalUsdAtomic, 'totalUsdAtomic');
  assertAtomicString(baseUsdPriceAtomic, 'baseUsdPriceAtomic');
  assertDecimals(usdDecimals, 'usdDecimals');
  assertDecimals(baseUsdPriceDecimals, 'baseUsdPriceDecimals');
  assertDecimals(baseDecimals, 'baseDecimals');

  const usd = BigInt(totalUsdAtomic);
  const basePriceUsd = BigInt(baseUsdPriceAtomic);

  if (basePriceUsd === 0n) {
    return null;
  }

  const exp = baseDecimals + baseUsdPriceDecimals - usdDecimals;
  let numerator = usd;
  let denominator = basePriceUsd;

  if (exp > 0) {
    numerator *= pow10(exp);
  } else if (exp < 0) {
    denominator *= pow10(-exp);
  }

  return divRoundHalfAwayFromZero(numerator, denominator).toString();
}

export function atomicToDecimalString(atomic: string, decimals: number): string {
  assertAtomicString(atomic, 'atomic');
  assertDecimals(decimals, 'decimals');

  const negative = atomic.startsWith('-');
  const digits = negative ? atomic.slice(1) : atomic;

  if (decimals === 0) {
    return `${negative ? '-' : ''}${digits}`;
  }

  const normalized = digits.padStart(decimals + 1, '0');
  const intPart = normalized.slice(0, normalized.length - decimals);
  const fracPart = normalized.slice(normalized.length - decimals);
  return `${negative ? '-' : ''}${intPart}.${fracPart}`;
}

export function decimalToAtomic(decimalValue: string, decimals: number): string {
  assertDecimals(decimals, 'decimals');

  const normalized = decimalValue.trim();
  const match = normalized.match(/^(-?)(\d+)(?:\.(\d+))?$/);
  if (!match) {
    throw new Error('Invalid decimal string');
  }

  const sign = match[1] === '-' ? -1n : 1n;
  const intPart = match[2];
  const fracPartRaw = match[3] ?? '';

  let fracPart = fracPartRaw;
  if (fracPart.length < decimals) {
    fracPart = fracPart.padEnd(decimals, '0');
  }

  let atomic = BigInt(intPart + fracPart.slice(0, decimals));

  if (fracPartRaw.length > decimals) {
    const nextDigit = fracPartRaw.charCodeAt(decimals) - 48;
    if (nextDigit >= 5) {
      atomic += 1n;
    }
  }

  atomic *= sign;
  return atomic.toString();
}

export function numberToAtomic(value: number, decimals: number): string {
  if (!Number.isFinite(value)) {
    throw new Error('Invalid number');
  }
  assertDecimals(decimals, 'decimals');

  const precision = Math.min(18, Math.max(decimals + 6, decimals));
  const asString = value.toFixed(precision);
  return decimalToAtomic(asString, decimals);
}
