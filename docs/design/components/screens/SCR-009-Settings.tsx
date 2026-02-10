import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { BottomNav } from '../ui/BottomNav';
import { ListRow } from '../ui/ListRow';
import { Banner } from '../ui/Banner';
import { Chip } from '../ui/Chip';
import { DollarSign, Crown, CreditCard } from 'lucide-react';
import { useState } from 'react';

export function SettingsScreen() {
  const [activeTab, setActiveTab] = useState(2);

  return (
    <ScreenWrapper screenId="009" screenName="Settings">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Settings" />

          <div style={{
            flex: 1,
            overflowY: 'auto',
            padding: 'var(--spacing-16)',
            paddingBottom: '80px'
          }}>
            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <Banner variant="warning" message="Couldn't verify subscription" />
              </div>
            )}

            {/* Account */}
            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
                Account
              </h3>
              <div style={{
                background: 'var(--surface)',
                borderRadius: 'var(--radius-12)',
                border: '1px solid var(--border)',
                overflow: 'hidden'
              }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 'var(--spacing-12)',
                  padding: 'var(--spacing-12) var(--spacing-16)'
                }}>
                  <div style={{ 
                    color: 'var(--text-secondary)',
                    display: 'flex',
                    alignItems: 'center'
                  }}>
                    <DollarSign size={20} />
                  </div>
                  <div style={{ flex: 1 }}>
                    <span className="text-body" style={{ fontWeight: 500 }}>Base currency</span>
                  </div>
                  <Chip variant="neutral">USD</Chip>
                </div>
              </div>
            </div>

            {/* Subscription */}
            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
                Subscription
              </h3>
              <div style={{
                background: 'var(--surface)',
                borderRadius: 'var(--radius-12)',
                border: '1px solid var(--border)',
                overflow: 'hidden'
              }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: 'var(--spacing-12)',
                  padding: 'var(--spacing-12) var(--spacing-16)'
                }}>
                  <div style={{ 
                    color: 'var(--text-secondary)',
                    display: 'flex',
                    alignItems: 'center'
                  }}>
                    <Crown size={20} />
                  </div>
                  <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 'var(--spacing-4)' }}>
                    <span className="text-body" style={{ fontWeight: 500 }}>Plan</span>
                    <span className="text-caption">Free</span>
                  </div>
                </div>
                <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                <ListRow
                  icon={<CreditCard size={20} />}
                  title="Manage subscription"
                  showChevron
                />
              </div>
            </div>

            {state === 'empty' && (
              <div style={{
                padding: 'var(--spacing-16)',
                background: 'var(--surface-alt)',
                borderRadius: 'var(--radius-12)',
                textAlign: 'center'
              }}>
                <p className="text-caption">No empty state</p>
              </div>
            )}

            {state === 'loading' && (
              <div style={{
                padding: 'var(--spacing-16)',
                background: 'var(--surface-alt)',
                borderRadius: 'var(--radius-12)',
                textAlign: 'center'
              }}>
                <p className="text-caption">Loading subscription status...</p>
              </div>
            )}
          </div>

          <div style={{ position: 'absolute', bottom: 0, left: 0, right: 0 }}>
            <BottomNav activeTab={activeTab} onTabChange={setActiveTab} />
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}
