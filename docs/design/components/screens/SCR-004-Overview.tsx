import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { BottomNav } from '../ui/BottomNav';
import { Card } from '../ui/Card';
import { ListRow } from '../ui/ListRow';
import { Banner } from '../ui/Banner';
import { StateBlock } from '../ui/StateBlock';
import { Button } from '../ui/Button';
import { Skeleton } from '../ui/Skeleton';
import { CreditCard, Wallet, AlertCircle, Plus } from 'lucide-react';
import { useState } from 'react';

export function OverviewScreen() {
  const [activeTab, setActiveTab] = useState(0);

  return (
    <ScreenWrapper screenId="004" screenName="Overview">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Overview" />

          <div style={{
            flex: 1,
            overflowY: 'auto',
            padding: 'var(--spacing-16)',
            paddingBottom: '80px'
          }}>
            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <Banner variant="error" message="Failed to sync data" />
                <div style={{ marginTop: 'var(--spacing-8)' }}>
                  <Banner variant="info" message="Offline — changes disabled" />
                </div>
              </div>
            )}

            {state === 'loading' ? (
              <>
                <div style={{ marginBottom: 'var(--spacing-16)' }}>
                  <Card>
                    <Skeleton type="total" />
                  </Card>
                </div>
                <Skeleton type="list" />
              </>
            ) : state === 'empty' ? (
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: 'var(--spacing-24)',
                paddingTop: 'var(--spacing-32)'
              }}>
                <StateBlock
                  variant="empty"
                  icon={<CreditCard size={64} />}
                  title="No accounts"
                  message="Create your first account to start tracking"
                  action={<Button variant="primary">Create account</Button>}
                />
                
                <div style={{
                  padding: 'var(--spacing-16)',
                  background: 'var(--surface)',
                  borderRadius: 'var(--radius-12)',
                  border: '1px solid var(--border)'
                }}>
                  <p className="text-caption" style={{ marginBottom: 'var(--spacing-12)', fontWeight: 600 }}>
                    Alternative empty states:
                  </p>
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-8)' }}>
                    <div style={{
                      padding: 'var(--spacing-12)',
                      background: 'var(--surface-alt)',
                      borderRadius: 'var(--radius-8)'
                    }}>
                      <p className="text-caption">
                        • Has accounts, no assets → "Add an asset"
                      </p>
                    </div>
                    <div style={{
                      padding: 'var(--spacing-12)',
                      background: 'var(--surface-alt)',
                      borderRadius: 'var(--radius-8)'
                    }}>
                      <p className="text-caption">
                        • Has assets, no balances → "Add a balance"
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            ) : (
              <>
                {/* Total Card with gradient */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    background: 'linear-gradient(135deg, var(--primary) 0%, #1E40AF 100%)',
                    borderRadius: 'var(--radius-16)',
                    padding: 'var(--spacing-24)',
                    boxShadow: '0 8px 16px rgba(37, 99, 235, 0.2)',
                    position: 'relative',
                    overflow: 'hidden'
                  }}>
                    {/* Decorative circle */}
                    <div style={{
                      position: 'absolute',
                      top: '-40px',
                      right: '-40px',
                      width: '160px',
                      height: '160px',
                      borderRadius: '50%',
                      background: 'rgba(255, 255, 255, 0.1)'
                    }} />
                    
                    <div style={{ position: 'relative', zIndex: 1 }}>
                      <p className="text-caption" style={{ color: 'rgba(255, 255, 255, 0.9)', marginBottom: 'var(--spacing-8)' }}>
                        Total balance
                      </p>
                      <h1 className="text-total-numeric" style={{ color: 'var(--surface)', marginBottom: 'var(--spacing-16)' }}>
                        $127,845.32
                      </h1>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: 'var(--spacing-8)',
                        padding: 'var(--spacing-8) var(--spacing-12)',
                        background: 'rgba(255, 255, 255, 0.15)',
                        borderRadius: 'var(--radius-8)',
                        backdropFilter: 'blur(10px)',
                        width: 'fit-content'
                      }}>
                        <div style={{
                          width: '6px',
                          height: '6px',
                          borderRadius: '50%',
                          background: '#16A34A'
                        }} />
                        <p className="text-caption" style={{ color: 'var(--surface)' }}>
                          Rates updated 5 minutes ago
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Accounts */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: 'var(--spacing-12)'
                  }}>
                    <h3 className="text-h3">Accounts</h3>
                    <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      2 active
                    </span>
                  </div>
                  <div style={{
                    background: 'var(--surface)',
                    borderRadius: 'var(--radius-16)',
                    border: '1px solid var(--border)',
                    overflow: 'hidden',
                    boxShadow: 'var(--elevation-1)'
                  }}>
                    <ListRow
                      icon={<CreditCard size={20} />}
                      title="Main Checking"
                      subtitle="Bank • 3 positions"
                      value="$45,234.12"
                      showChevron
                    />
                    <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                    <ListRow
                      icon={<Wallet size={20} />}
                      title="Crypto Wallet"
                      subtitle="Crypto wallet • 2 positions"
                      value="$82,611.20"
                      showChevron
                    />
                  </div>
                </div>

                {/* Missing rates section */}
                <div>
                  <Banner variant="warning" message="2 assets have no price data" />
                  <div style={{
                    marginTop: 'var(--spacing-12)',
                    padding: 'var(--spacing-16)',
                    background: 'var(--surface)',
                    borderRadius: 'var(--radius-12)',
                    border: '1px solid var(--border)',
                    display: 'flex',
                    justifyContent: 'space-between',
                    alignItems: 'center'
                  }}>
                    <p className="text-caption" style={{ color: 'var(--text-secondary)' }}>
                      Priced total
                    </p>
                    <p className="text-body" style={{ fontWeight: 600, fontVariantNumeric: 'tabular-nums' }}>
                      $127,845.32
                    </p>
                  </div>
                </div>
              </>
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