import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { Card } from '../ui/Card';
import { Chip } from '../ui/Chip';
import { Button } from '../ui/Button';
import { Banner } from '../ui/Banner';
import { ExternalLink } from 'lucide-react';

export function ManageSubscriptionScreen() {
  return (
    <ScreenWrapper screenId="014" screenName="Manage subscription">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Subscription" showBack />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)'
          }}>
            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <Banner variant="warning" message="Couldn't verify subscription" />
              </div>
            )}

            {state === 'empty' && (
              <div style={{
                padding: 'var(--spacing-32)',
                textAlign: 'center'
              }}>
                <p className="text-body" style={{ color: 'var(--text-secondary)' }}>
                  No empty state
                </p>
              </div>
            )}

            {state !== 'empty' && (
              <>
                {/* Status Card */}
                <div style={{ marginBottom: 'var(--spacing-24)' }}>
                  <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
                    Current plan
                  </h3>
                  <Card>
                    <div style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      marginBottom: 'var(--spacing-12)'
                    }}>
                      <div>
                        <h3 className="text-h3">
                          {state === 'loading' ? 'Loading...' : 'Free'}
                        </h3>
                        <p className="text-caption" style={{ marginTop: 'var(--spacing-4)' }}>
                          {state === 'loading' ? 'Checking status...' : 'Active'}
                        </p>
                      </div>
                      {state !== 'loading' && <Chip variant="neutral">Free</Chip>}
                    </div>
                    <p className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      5 accounts, 20 positions
                    </p>
                  </Card>
                </div>

                {/* Actions */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-12)' }}>
                  <Button variant="secondary" disabled={state === 'loading'}>
                    <ExternalLink size={16} />
                    Manage in App Store
                  </Button>
                  <Button variant="tertiary" disabled={state === 'loading'}>
                    Restore purchases
                  </Button>
                </div>

                {state === 'error' && (
                  <div style={{ marginTop: 'var(--spacing-16)' }}>
                    <Button variant="primary">
                      Try again
                    </Button>
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
