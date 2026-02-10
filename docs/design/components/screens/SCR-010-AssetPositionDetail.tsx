import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { Card } from '../ui/Card';
import { ListRow } from '../ui/ListRow';
import { Button } from '../ui/Button';
import { Skeleton } from '../ui/Skeleton';
import { MoreVertical, Plus, Calendar } from 'lucide-react';

export function AssetPositionDetailScreen() {
  const history = [
    { date: 'Feb 10, 2026', amount: '100', type: 'Snapshot' },
    { date: 'Feb 1, 2026', amount: '+5', type: 'Change' },
    { date: 'Jan 15, 2026', amount: '95', type: 'Snapshot' },
  ];

  return (
    <ScreenWrapper screenId="010" screenName="Asset position detail">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="AAPL" showBack trailingIcon={<MoreVertical size={20} />} />

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
                    <p className="text-caption" style={{ marginBottom: 'var(--spacing-4)' }}>
                      Apple Inc.
                    </p>
                    <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-12)' }}>
                      0 shares
                    </h2>
                    <div style={{
                      display: 'inline-flex',
                      alignItems: 'center',
                      gap: 'var(--spacing-8)',
                      padding: '6px 12px',
                      background: 'var(--surface-alt)',
                      borderRadius: 'var(--radius-8)',
                      border: '1px solid var(--border)'
                    }}>
                      <p className="text-caption">Stock</p>
                      <div style={{ width: '1px', height: '12px', background: 'var(--border)' }} />
                      <p className="text-caption" style={{ color: 'var(--text-tertiary)' }}>Unpriced</p>
                    </div>
                  </div>
                </div>
                <div style={{
                  padding: 'var(--spacing-48)',
                  textAlign: 'center'
                }}>
                  <div style={{
                    width: '80px',
                    height: '80px',
                    margin: '0 auto var(--spacing-16)',
                    borderRadius: '50%',
                    background: 'var(--surface-alt)',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center'
                  }}>
                    <Calendar size={40} style={{ color: 'var(--text-tertiary)' }} />
                  </div>
                  <p className="text-h3" style={{ marginBottom: 'var(--spacing-8)' }}>
                    No balance history yet
                  </p>
                  <p className="text-body" style={{ color: 'var(--text-secondary)', marginBottom: 'var(--spacing-24)' }}>
                    Add your first balance entry to start tracking
                  </p>
                  <Button variant="primary">
                    <Plus size={20} />
                    Add balance
                  </Button>
                </div>
              </div>
            ) : (
              <>
                {/* Summary with enhanced design */}
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
                      <p className="text-caption" style={{ marginBottom: 'var(--spacing-4)' }}>
                        Apple Inc.
                      </p>
                      <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-12)' }}>
                        100 shares
                      </h2>
                      <div style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        padding: 'var(--spacing-12)',
                        background: 'var(--surface-alt)',
                        borderRadius: 'var(--radius-8)',
                        border: '1px solid var(--border)'
                      }}>
                        <p className="text-caption">
                          Stock • $189.50/share
                        </p>
                        <p className="text-h3" style={{ fontVariantNumeric: 'tabular-nums' }}>
                          $18,950.00
                        </p>
                      </div>
                    </div>
                  </div>
                </div>

                {/* History */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: 'var(--spacing-12)'
                  }}>
                    <h3 className="text-h3">Balance history</h3>
                    <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      {history.length} entries
                    </span>
                  </div>
                  <div style={{
                    background: 'var(--surface)',
                    borderRadius: 'var(--radius-16)',
                    border: '1px solid var(--border)',
                    overflow: 'hidden',
                    boxShadow: 'var(--elevation-1)'
                  }}>
                    {history.map((entry, index) => (
                      <div key={index}>
                        <ListRow
                          icon={<Calendar size={20} />}
                          title={entry.amount}
                          subtitle={entry.type}
                          value={entry.date}
                        />
                        {index < history.length - 1 && (
                          <div style={{ height: '1px', background: 'var(--border)', marginLeft: '68px' }} />
                        )}
                      </div>
                    ))}
                  </div>
                  <button style={{
                    width: '100%',
                    padding: 'var(--spacing-12)',
                    marginTop: 'var(--spacing-12)',
                    background: 'transparent',
                    border: 'none',
                    cursor: 'pointer',
                    color: 'var(--primary)',
                    fontSize: '14px',
                    fontWeight: 500
                  }}>
                    Load more
                  </button>
                </div>

                {/* Add Button */}
                <Button variant="primary">
                  <Plus size={20} />
                  Add balance
                </Button>
              </>
            )}
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}