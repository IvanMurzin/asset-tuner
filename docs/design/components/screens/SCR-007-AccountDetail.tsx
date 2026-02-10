import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { Card } from '../ui/Card';
import { ListRow } from '../ui/ListRow';
import { Button } from '../ui/Button';
import { Dialog } from '../ui/Dialog';
import { Skeleton } from '../ui/Skeleton';
import { MoreVertical, TrendingUp, Coins, Plus } from 'lucide-react';

export function AccountDetailScreen() {
  return (
    <ScreenWrapper screenId="007" screenName="Account detail">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Main Checking" showBack trailingIcon={<MoreVertical size={20} />} />

          <div style={{
            flex: 1,
            overflowY: 'auto',
            padding: 'var(--spacing-16)'
          }}>
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
              <div>
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    background: 'var(--surface)',
                    borderRadius: 'var(--radius-16)',
                    padding: 'var(--spacing-24)',
                    border: '1px solid var(--border)',
                    boxShadow: 'var(--elevation-1)'
                  }}>
                    <p className="text-caption" style={{ marginBottom: 'var(--spacing-8)' }}>
                      Account total
                    </p>
                    <h1 className="text-total-numeric" style={{ marginBottom: 'var(--spacing-12)' }}>
                      $0.00
                    </h1>
                    <div style={{
                      display: 'inline-flex',
                      padding: '6px 12px',
                      background: 'var(--surface-alt)',
                      borderRadius: 'var(--radius-8)',
                      border: '1px solid var(--border)'
                    }}>
                      <p className="text-caption">Bank</p>
                    </div>
                  </div>
                </div>
                <div style={{
                  padding: 'var(--spacing-48)',
                  textAlign: 'center'
                }}>
                  <div style={{
                    width: '64px',
                    height: '64px',
                    margin: '0 auto var(--spacing-16)',
                    borderRadius: '50%',
                    background: 'var(--surface-alt)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}>
                    <TrendingUp size={32} style={{ color: 'var(--text-tertiary)' }} />
                  </div>
                  <p className="text-body" style={{ color: 'var(--text-secondary)', marginBottom: 'var(--spacing-8)' }}>
                    No positions yet
                  </p>
                  <p className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                    Add your first asset to start tracking
                  </p>
                </div>
              </div>
            ) : (
              <>
                {/* Account Total with enhanced design */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    background: 'var(--surface)',
                    borderRadius: 'var(--radius-16)',
                    padding: 'var(--spacing-24)',
                    border: '1px solid var(--border)',
                    boxShadow: 'var(--elevation-2)',
                    position: 'relative',
                    overflow: 'hidden'
                  }}>
                    {/* Subtle gradient overlay */}
                    <div style={{
                      position: 'absolute',
                      top: 0,
                      right: 0,
                      width: '120px',
                      height: '120px',
                      background: 'radial-gradient(circle, rgba(37, 99, 235, 0.08) 0%, transparent 70%)',
                      pointerEvents: 'none'
                    }} />
                    
                    <div style={{ position: 'relative', zIndex: 1 }}>
                      <p className="text-caption" style={{ marginBottom: 'var(--spacing-8)' }}>
                        Account total
                      </p>
                      <h1 className="text-total-numeric" style={{ marginBottom: 'var(--spacing-12)' }}>
                        $45,234.12
                      </h1>
                      <div style={{
                        display: 'inline-flex',
                        padding: '6px 12px',
                        background: 'var(--surface-alt)',
                        borderRadius: 'var(--radius-8)',
                        border: '1px solid var(--border)'
                      }}>
                        <p className="text-caption">Bank</p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Positions */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: 'var(--spacing-12)'
                  }}>
                    <h3 className="text-h3">Positions</h3>
                    <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      3 assets
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
                      icon={<TrendingUp size={20} />}
                      title="AAPL"
                      subtitle="100 shares"
                      value="$18,950.00"
                      showChevron
                    />
                    <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                    <ListRow
                      icon={<Coins size={20} />}
                      title="USD"
                      subtitle="25,000.00 USD"
                      value="$25,000.00"
                      showChevron
                    />
                    <div style={{ height: '1px', background: 'var(--border)', marginLeft: '52px' }} />
                    <ListRow
                      icon={<TrendingUp size={20} />}
                      title="TSLA"
                      subtitle="5 shares • Unpriced"
                      value="—"
                      showChevron
                    />
                  </div>
                </div>

                {/* Add Button */}
                <Button variant="primary">
                  <Plus size={20} />
                  Add asset
                </Button>

                {/* Remove Dialog */}
                {state === 'default' && (
                  <div style={{ marginTop: 'var(--spacing-24)' }}>
                    <Dialog
                      variant="destructive"
                      title="Remove asset"
                      message="This will remove the position and its history"
                      onConfirm={() => {}}
                      onCancel={() => {}}
                    />
                  </div>
                )}
              </>
            )}
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}