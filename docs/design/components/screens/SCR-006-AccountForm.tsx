import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { TextField } from '../ui/TextField';
import { Button } from '../ui/Button';
import { ListRow } from '../ui/ListRow';
import { CreditCard, Wallet, Banknote, Folder } from 'lucide-react';

export function AccountFormScreen() {
  const types = [
    { id: 'bank', name: 'Bank', icon: <CreditCard size={20} /> },
    { id: 'crypto', name: 'Crypto wallet', icon: <Wallet size={20} /> },
    { id: 'cash', name: 'Cash', icon: <Banknote size={20} /> },
    { id: 'other', name: 'Other', icon: <Folder size={20} /> },
  ];

  return (
    <ScreenWrapper screenId="006" screenName="Account form">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="New account" showBack />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)'
          }}>
            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <TextField
                label="Account name"
                placeholder="My account"
                disabled={state === 'loading'}
              />
            </div>

            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <label className="text-caption" style={{
                display: 'block',
                marginBottom: 'var(--spacing-12)',
                color: 'var(--text-primary)',
                fontWeight: 500
              }}>
                Type
              </label>
              <div style={{
                background: 'var(--surface)',
                borderRadius: 'var(--radius-12)',
                border: '1px solid var(--border)',
                overflow: 'hidden'
              }}>
                {types.map((type, index) => (
                  <div key={type.id}>
                    <ListRow
                      icon={type.icon}
                      title={type.name}
                      variant={index === 0 ? 'selected' : 'default'}
                    />
                    {index < types.length - 1 && (
                      <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                    )}
                  </div>
                ))}
              </div>
            </div>

            {state === 'empty' && (
              <div style={{ marginBottom: 'var(--spacing-24)' }}>
                <p className="text-caption" style={{ textAlign: 'center' }}>
                  No empty state
                </p>
              </div>
            )}

            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-24)' }}>
                <p className="text-caption" style={{ color: 'var(--danger)', textAlign: 'center' }}>
                  Account limit reached (5/5)
                </p>
              </div>
            )}

            <div style={{ marginTop: 'auto' }}>
              <Button
                variant="primary"
                loading={state === 'loading'}
                disabled={state === 'loading' || state === 'error'}
              >
                Save
              </Button>
              {state === 'error' && (
                <p className="text-caption" style={{
                  color: 'var(--text-secondary)',
                  textAlign: 'center',
                  marginTop: 'var(--spacing-8)'
                }}>
                  Upgrade to add more accounts
                </p>
              )}
            </div>
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}
