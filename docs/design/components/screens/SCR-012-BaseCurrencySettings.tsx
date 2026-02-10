import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { Card } from '../ui/Card';
import { TextField } from '../ui/TextField';
import { ListRow } from '../ui/ListRow';
import { Button } from '../ui/Button';
import { Chip } from '../ui/Chip';
import { Lock, DollarSign, Euro, Coins } from 'lucide-react';

export function BaseCurrencySettingsScreen() {
  const currencies = [
    { code: 'USD', name: 'US Dollar', icon: <DollarSign size={20} />, locked: false },
    { code: 'EUR', name: 'Euro', icon: <Euro size={20} />, locked: false },
    { code: 'RUB', name: 'Russian Ruble', icon: <Coins size={20} />, locked: false },
    { code: 'GBP', name: 'British Pound', icon: <Coins size={20} />, locked: true },
    { code: 'JPY', name: 'Japanese Yen', icon: <Coins size={20} />, locked: true },
  ];

  return (
    <ScreenWrapper screenId="012" screenName="Base currency settings">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Base currency" showBack />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)'
          }}>
            {/* Current */}
            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
                Current
              </h3>
              <Card>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between'
                }}>
                  <div>
                    <p className="text-h3">USD</p>
                    <p className="text-caption">US Dollar</p>
                  </div>
                  <Chip variant="primary">Active</Chip>
                </div>
              </Card>
            </div>

            {/* Search */}
            <div style={{ marginBottom: 'var(--spacing-16)' }}>
              <TextField
                label="Search"
                placeholder="Search currencies"
                disabled={state === 'loading'}
              />
            </div>

            {/* Currency List */}
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
                <>
                  <label className="text-caption" style={{
                    display: 'block',
                    marginBottom: 'var(--spacing-12)',
                    color: 'var(--text-primary)',
                    fontWeight: 500
                  }}>
                    Fiat currencies
                  </label>
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
                          variant={currency.locked ? 'disabled' : (index === 1 ? 'selected' : 'default')}
                        />
                        {index < currencies.length - 1 && (
                          <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                        )}
                      </div>
                    ))}
                  </div>
                  {state === 'default' && (
                    <p className="text-caption" style={{
                      marginTop: 'var(--spacing-8)',
                      color: 'var(--text-secondary)'
                    }}>
                      Free plan includes USD, EUR, RUB
                    </p>
                  )}
                </>
              )}
            </div>

            {/* Save Button */}
            <Button
              variant="primary"
              loading={state === 'loading'}
              disabled={state === 'loading' || state === 'empty'}
            >
              Save
            </Button>
            {state === 'error' && (
              <p className="text-caption" style={{
                color: 'var(--text-secondary)',
                textAlign: 'center',
                marginTop: 'var(--spacing-8)'
              }}>
                Upgrade to unlock all currencies
              </p>
            )}
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}
