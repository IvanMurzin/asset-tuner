import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { SegmentedControl } from '../ui/SegmentedControl';
import { DateField } from '../ui/DateField';
import { AmountField } from '../ui/AmountField';
import { Button } from '../ui/Button';
import { Banner } from '../ui/Banner';
import { useState } from 'react';

export function AddBalanceScreen() {
  const [balanceType, setBalanceType] = useState<'snapshot' | 'change'>('snapshot');

  return (
    <ScreenWrapper screenId="011" screenName="Add balance">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Add balance" showBack />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)'
          }}>
            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <Banner variant="info" message="Offline — changes disabled" />
              </div>
            )}

            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <label className="text-caption" style={{
                display: 'block',
                marginBottom: 'var(--spacing-12)',
                color: 'var(--text-primary)',
                fontWeight: 500
              }}>
                Type
              </label>
              <SegmentedControl value={balanceType} onChange={setBalanceType} />
            </div>

            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <DateField label="Date" value="Feb 10, 2026" />
            </div>

            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <AmountField 
                label={balanceType === 'snapshot' ? 'Amount' : 'Change'}
                value={balanceType === 'snapshot' ? '100.00' : '+5.00'}
              />
              {state === 'error' && (
                <p className="text-caption" style={{
                  color: 'var(--text-secondary)',
                  marginTop: 'var(--spacing-8)'
                }}>
                  Offline — changes disabled
                </p>
              )}
            </div>

            {state === 'empty' && (
              <div style={{ marginBottom: 'var(--spacing-24)' }}>
                <p className="text-caption" style={{ textAlign: 'center' }}>
                  No empty state
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
            </div>
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}
