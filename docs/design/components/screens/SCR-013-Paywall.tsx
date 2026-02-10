import { ScreenWrapper } from './ScreenWrapper';
import { TopBar } from '../ui/TopBar';
import { Card } from '../ui/Card';
import { Badge } from '../ui/Badge';
import { Button } from '../ui/Button';
import { Banner } from '../ui/Banner';
import { Skeleton } from '../ui/Skeleton';
import { Check } from 'lucide-react';

export function PaywallScreen() {
  const benefits = [
    'Unlimited accounts and positions',
    'All base currencies',
    'Priority support',
    'Advanced analytics',
  ];

  return (
    <ScreenWrapper screenId="013" screenName="Paywall">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          <TopBar title="Upgrade" showBack />

          <div style={{
            flex: 1,
            display: 'flex',
            flexDirection: 'column',
            padding: 'var(--spacing-16)',
            overflowY: 'auto'
          }}>
            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <Banner variant="error" message="Purchase failed — please try again" />
              </div>
            )}

            {/* Premium Badge */}
            <div style={{
              display: 'flex',
              justifyContent: 'center',
              marginBottom: 'var(--spacing-24)'
            }}>
              <div style={{
                display: 'inline-flex',
                padding: '12px 20px',
                background: 'linear-gradient(135deg, var(--primary) 0%, #1E40AF 100%)',
                borderRadius: 'var(--radius-12)',
                boxShadow: '0 4px 12px rgba(37, 99, 235, 0.3)'
              }}>
                <span style={{
                  fontSize: '24px',
                  fontWeight: 700,
                  color: 'var(--surface)'
                }}>
                  ⭐ Premium
                </span>
              </div>
            </div>

            {/* Reason */}
            <div style={{ marginBottom: 'var(--spacing-24)', textAlign: 'center' }}>
              <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-8)' }}>
                {state === 'empty' ? 'Base currency locked' : 'Account limit reached'}
              </h2>
              <p className="text-body" style={{ color: 'var(--text-secondary)' }}>
                {state === 'empty' 
                  ? 'Upgrade to use any base currency'
                  : 'Upgrade to add more accounts and positions'}
              </p>
            </div>

            {/* Benefits */}
            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-16)' }}>
                What's included
              </h3>
              <div style={{
                background: 'var(--surface)',
                padding: 'var(--spacing-20)',
                borderRadius: 'var(--radius-16)',
                border: '1px solid var(--border)',
                boxShadow: 'var(--elevation-1)'
              }}>
                {benefits.map((benefit, index) => (
                  <div key={index} style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 'var(--spacing-12)',
                    marginBottom: index < benefits.length - 1 ? 'var(--spacing-16)' : 0
                  }}>
                    <div style={{
                      width: '24px',
                      height: '24px',
                      borderRadius: '50%',
                      background: 'linear-gradient(135deg, #16A34A 0%, #15803D 100%)',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      color: 'var(--on-primary)',
                      flexShrink: 0
                    }}>
                      <Check size={16} strokeWidth={3} />
                    </div>
                    <span className="text-body" style={{ fontWeight: 500 }}>{benefit}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Plans */}
            {state === 'loading' ? (
              <div style={{ marginBottom: 'var(--spacing-24)' }}>
                <Skeleton type="list" />
              </div>
            ) : (
              <div style={{ marginBottom: 'var(--spacing-24)' }}>
                <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-16)' }}>
                  Choose plan
                </h3>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-12)' }}>
                  {/* Annual Plan - Recommended */}
                  <div style={{
                    position: 'relative',
                    background: 'var(--surface)',
                    padding: 'var(--spacing-20)',
                    borderRadius: 'var(--radius-16)',
                    border: '2px solid var(--primary)',
                    boxShadow: '0 4px 12px rgba(37, 99, 235, 0.15)',
                    cursor: 'pointer'
                  }}>
                    <div style={{
                      position: 'absolute',
                      top: '-12px',
                      right: '16px',
                      padding: '4px 12px',
                      background: 'linear-gradient(135deg, var(--primary) 0%, #1E40AF 100%)',
                      borderRadius: 'var(--radius-8)',
                      boxShadow: 'var(--elevation-1)'
                    }}>
                      <span className="text-caption" style={{ color: 'var(--surface)', fontWeight: 600 }}>
                        BEST VALUE
                      </span>
                    </div>
                    <div style={{
                      display: 'flex',
                      alignItems: 'flex-start',
                      justifyContent: 'space-between',
                      marginBottom: 'var(--spacing-8)'
                    }}>
                      <div>
                        <h3 className="text-h3">Annual</h3>
                        <p className="text-caption" style={{ marginTop: 'var(--spacing-4)' }}>
                          $89.99/year
                        </p>
                      </div>
                      <div style={{
                        padding: '6px 12px',
                        background: 'rgba(22, 163, 74, 0.1)',
                        borderRadius: 'var(--radius-8)',
                        border: '1px solid rgba(22, 163, 74, 0.2)'
                      }}>
                        <span style={{
                          fontSize: '13px',
                          fontWeight: 600,
                          color: '#16A34A'
                        }}>
                          Save 25%
                        </span>
                      </div>
                    </div>
                    <p className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      $7.49/month — Save $30/year
                    </p>
                  </div>

                  {/* Monthly Plan */}
                  <div style={{
                    background: 'var(--surface)',
                    padding: 'var(--spacing-20)',
                    borderRadius: 'var(--radius-16)',
                    border: '1px solid var(--border)',
                    cursor: 'pointer'
                  }}>
                    <div style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      marginBottom: 'var(--spacing-8)'
                    }}>
                      <div>
                        <h3 className="text-h3">Monthly</h3>
                        <p className="text-caption" style={{ marginTop: 'var(--spacing-4)' }}>
                          $9.99/month
                        </p>
                      </div>
                    </div>
                    <p className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                      Flexible monthly billing
                    </p>
                  </div>
                </div>
              </div>
            )}

            {/* Actions */}
            <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: 'var(--spacing-12)', paddingTop: 'var(--spacing-16)' }}>
              <Button
                variant="primary"
                disabled={state === 'loading'}
              >
                Upgrade to Premium
              </Button>
              <Button variant="tertiary">
                Not now
              </Button>
              <p className="text-caption" style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>
                Cancel anytime • Secure payment
              </p>
            </div>
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}