export type Plan = 'free' | 'paid';

export type Entitlements = {
  max_accounts: number;
  max_positions: number;
  any_base_currency: boolean;
  allowed_base_currency_codes: string[];
  expires_at: string | null;
};

export function normalizePlan(plan: string | null | undefined): Plan {
  return plan === 'paid' ? 'paid' : 'free';
}

export function entitlementsForPlan(plan: Plan): Entitlements {
  if (plan === 'paid') {
    return {
      max_accounts: 999,
      max_positions: 9999,
      any_base_currency: true,
      allowed_base_currency_codes: [],
      expires_at: null,
    };
  }
  return {
    max_accounts: 5,
    max_positions: 20,
    any_base_currency: false,
    allowed_base_currency_codes: ['USD', 'EUR', 'RUB'],
    expires_at: null,
  };
}

