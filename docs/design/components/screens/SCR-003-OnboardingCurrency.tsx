import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { TextField } from '../ui/TextField';
import { Button } from '../ui/Button';
import { ListRow } from '../ui/ListRow';
import { Lock, DollarSign, Euro, Coins } from 'lucide-react';

export function OnboardingCurrencyScreen() {
  const currencies = [
    { code: 'USD', name: 'US Dollar', icon: <DollarSign size={20} />, locked: false },
    { code: 'EUR', name: 'Euro', icon: <Euro size={20} />, locked: false },
    { code: 'RUB', name: 'Russian Ruble', icon: <Coins size={20} />, locked: false },
    { code: 'GBP', name: 'British Pound', icon: <Coins size={20} />, locked: true },
    { code: 'JPY', name: 'Japanese Yen', icon: <Coins size={20} />, locked: true },
  ];

  return (
    <ScreenWrapper screenId="003" screenName="Onboarding: Base currency">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Base currency" />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)'
          }}>
            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <p className="text-body" style={{ color: 'var(--text-secondary)' }}>
                Choose your primary currency. All positions will be converted to this currency.
              </p>
            </div>

            <div style={{ marginBottom: 'var(--spacing-16)' }}>
              <TextField
                label="Search"
                placeholder="Search currencies"
                disabled={state === 'loading'}
              />
            </div>

            <div style={{ flex: 1, marginBottom: 'var(--spacing-16)' }}>
              {state === 'empty' ? (
                <div style={{
                  padding: 'var(--spacing-32)',
                  textAlign: 'center'
                }}>
                  <p className="text-body" style={{ color: 'var(--text-secondary)' }}>
                    No currencies
                  </p>
                </div>
              ) : (
                <div style={{
                  background: 'var(--surface)',
                  borderRadius: 'var(--radius-12)',
                  border: '1px solid var(--border)',
                  overflow: 'hidden'
                }}>
                  {currencies.map((currency, index) => (
                    <div key={currency.code}>
                      <ListRow
                        icon={currency.locked ? <Lock size={20} /> : currency.icon}
                        title={currency.code}
                        subtitle={currency.name}
                        variant={currency.locked ? 'disabled' : 'default'}
                      />
                      {index < currencies.length - 1 && (
                        <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>

            <Button
              variant="primary"
              loading={state === 'loading'}
              disabled={state === 'loading'}
            >
              Continue
            </Button>
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}
