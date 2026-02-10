import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { TextField } from '../ui/TextField';
import { ListRow } from '../ui/ListRow';
import { Button } from '../ui/Button';
import { Skeleton } from '../ui/Skeleton';
import { TrendingUp, Coins, DollarSign } from 'lucide-react';

export function AddAssetScreen() {
  const assets = [
    { symbol: 'AAPL', name: 'Apple Inc.', type: 'Stock', icon: <TrendingUp size={20} /> },
    { symbol: 'BTC', name: 'Bitcoin', type: 'Crypto', icon: <Coins size={20} /> },
    { symbol: 'USD', name: 'US Dollar', type: 'Currency', icon: <DollarSign size={20} /> },
    { symbol: 'TSLA', name: 'Tesla Inc.', type: 'Stock', icon: <TrendingUp size={20} /> },
  ];

  return (
    <ScreenWrapper screenId="008" screenName="Add asset">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Add asset" showBack />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)'
          }}>
            <div style={{ marginBottom: 'var(--spacing-16)' }}>
              <TextField
                label="Search"
                placeholder="Search stocks, crypto, currencies"
                helper={state === 'error' ? 'Asset already in this account' : undefined}
                error={state === 'error' ? 'Duplicate not allowed' : undefined}
                disabled={state === 'loading'}
              />
            </div>

            <div style={{ flex: 1, marginBottom: 'var(--spacing-16)' }}>
              {state === 'loading' ? (
                <Skeleton type="list" />
              ) : state === 'empty' ? (
                <div style={{
                  padding: 'var(--spacing-32)',
                  textAlign: 'center'
                }}>
                  <p className="text-body" style={{ color: 'var(--text-secondary)' }}>
                    No matches
                  </p>
                </div>
              ) : (
                <div style={{
                  background: 'var(--surface)',
                  borderRadius: 'var(--radius-12)',
                  border: '1px solid var(--border)',
                  overflow: 'hidden'
                }}>
                  {assets.map((asset, index) => (
                    <div key={asset.symbol}>
                      <ListRow
                        icon={asset.icon}
                        title={asset.symbol}
                        subtitle={asset.name}
                        variant={index === 0 ? 'selected' : 'default'}
                      />
                      {index < assets.length - 1 && (
                        <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>

            <Button
              variant="primary"
              disabled={state === 'loading' || state === 'empty' || state === 'error'}
            >
              Add
            </Button>

            {state === 'error' && (
              <p className="text-caption" style={{
                color: 'var(--text-secondary)',
                textAlign: 'center',
                marginTop: 'var(--spacing-8)'
              }}>
                Position limit reached (20/20) — Upgrade for more
              </p>
            )}
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}
