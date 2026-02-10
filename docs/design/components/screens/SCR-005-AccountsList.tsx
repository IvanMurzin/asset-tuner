import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { BottomNav } from '../ui/BottomNav';
import { ListRow } from '../ui/ListRow';
import { Button } from '../ui/Button';
import { Dialog } from '../ui/Dialog';
import { Skeleton } from '../ui/Skeleton';
import { CreditCard, Wallet, Plus } from 'lucide-react';
import { useState } from 'react';

export function AccountsListScreen() {
  const [activeTab, setActiveTab] = useState(1);
  const [showDialog, setShowDialog] = useState(false);

  return (
    <ScreenWrapper screenId="005" screenName="Accounts list">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Accounts" />

          <div style={{
            flex: 1,
            overflowY: 'auto',
            padding: 'var(--spacing-16)',
            paddingBottom: '80px'
          }}>
            {state === 'loading' ? (
              <Skeleton type="list" />
            ) : state === 'empty' ? (
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
                  <CreditCard size={40} style={{ color: 'var(--text-tertiary)' }} />
                </div>
                <p className="text-h3" style={{ marginBottom: 'var(--spacing-8)' }}>
                  No accounts yet
                </p>
                <p className="text-body" style={{ color: 'var(--text-secondary)' }}>
                  Create your first account to start
                </p>
              </div>
            ) : (
              <>
                {/* Active Accounts */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: 'var(--spacing-12)'
                  }}>
                    <h3 className="text-h3">Active</h3>
                    <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      3 accounts
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
                      subtitle="Bank"
                      value="$45,234.12"
                      showChevron
                    />
                    <div style={{ height: '1px', background: 'var(--border)', marginLeft: '68px' }} />
                    <ListRow
                      icon={<Wallet size={20} />}
                      title="Crypto Wallet"
                      subtitle="Crypto wallet"
                      value="$82,611.20"
                      showChevron
                    />
                    <div style={{ height: '1px', background: 'var(--border)', marginLeft: '68px' }} />
                    <ListRow
                      icon={<Wallet size={20} />}
                      title="Cash Reserve"
                      subtitle="Cash"
                      value="$5,000.00"
                      showChevron
                    />
                  </div>
                </div>

                {/* Archived */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <div style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    marginBottom: 'var(--spacing-12)'
                  }}>
                    <h3 className="text-h3">Archived</h3>
                    <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      1 account
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
                      title="Old Savings"
                      subtitle="Bank"
                      variant="disabled"
                      showChevron
                    />
                  </div>
                </div>

                {/* Add Button */}
                <Button variant="primary">
                  <Plus size={20} />
                  Add account
                </Button>

                {/* Dialog Examples */}
                {state === 'default' && (
                  <div style={{
                    marginTop: 'var(--spacing-24)',
                    display: 'flex',
                    flexDirection: 'column',
                    gap: 'var(--spacing-16)'
                  }}>
                    <Dialog
                      variant="neutral"
                      title="Archive account"
                      message="This will hide the account from overview"
                      onConfirm={() => {}}
                      onCancel={() => {}}
                    />
                    <Dialog
                      variant="destructive"
                      title="Delete account"
                      message="This will permanently delete all data"
                      onConfirm={() => {}}
                      onCancel={() => {}}
                    />
                  </div>
                )}
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