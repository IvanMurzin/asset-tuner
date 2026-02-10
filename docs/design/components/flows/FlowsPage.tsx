import { Link } from 'react-router';
import { ArrowRight } from 'lucide-react';

export function FlowsPage() {
  const journeys = [
    {
      id: 'JRN-01',
      name: 'First launch',
      steps: [
        { screen: 'SCR-001', name: 'Splash', path: '/splash' },
        { screen: 'SCR-002', name: 'Sign-in', path: '/sign-in' },
        { screen: 'SCR-003', name: 'Base currency', path: '/onboarding-currency' },
        { screen: 'SCR-004', name: 'Overview', path: '/overview' },
      ]
    },
    {
      id: 'JRN-02',
      name: 'Create account + add asset',
      steps: [
        { screen: 'SCR-004', name: 'Overview', path: '/overview' },
        { screen: 'SCR-005', name: 'Accounts', path: '/accounts' },
        { screen: 'SCR-006', name: 'Account form', path: '/account-form' },
        { screen: 'SCR-007', name: 'Account detail', path: '/account-detail' },
        { screen: 'SCR-008', name: 'Add asset', path: '/add-asset' },
        { screen: 'SCR-007', name: 'Account detail', path: '/account-detail' },
        { screen: 'SCR-004', name: 'Overview', path: '/overview' },
      ]
    },
    {
      id: 'JRN-03',
      name: 'Drilldown + add balance',
      steps: [
        { screen: 'SCR-004', name: 'Overview', path: '/overview' },
        { screen: 'SCR-007', name: 'Account detail', path: '/account-detail' },
        { screen: 'SCR-010', name: 'Asset detail', path: '/asset-detail' },
        { screen: 'SCR-011', name: 'Add balance', path: '/add-balance' },
        { screen: 'SCR-010', name: 'Asset detail', path: '/asset-detail' },
        { screen: 'SCR-004', name: 'Overview', path: '/overview' },
      ]
    },
    {
      id: 'JRN-04',
      name: 'Change base currency (gated)',
      steps: [
        { screen: 'SCR-004', name: 'Overview', path: '/overview' },
        { screen: 'SCR-009', name: 'Settings', path: '/settings' },
        { screen: 'SCR-012', name: 'Base currency', path: '/base-currency-settings' },
        { screen: 'SCR-013', name: 'Paywall', path: '/paywall' },
        { screen: 'SCR-012', name: 'Base currency', path: '/base-currency-settings' },
      ]
    },
    {
      id: 'JRN-05',
      name: 'Upgrade then retry',
      steps: [
        { screen: 'SCR-006/008/012', name: 'Gated screen', path: '/account-form' },
        { screen: 'SCR-013', name: 'Paywall', path: '/paywall' },
        { screen: 'Return', name: 'Origin screen', path: '/account-form' },
      ]
    },
  ];

  return (
    <div className="min-h-screen" style={{ 
      background: 'var(--bg)',
      padding: 'var(--spacing-16)'
    }}>
      <div style={{ maxWidth: '1200px', margin: '0 auto' }}>
        <div style={{ marginBottom: 'var(--spacing-24)' }}>
          <h1 className="text-h1">Asset Tuner</h1>
          <p className="text-caption" style={{ marginTop: 'var(--spacing-4)' }}>
            02_Flows — Clickable Prototype
          </p>
        </div>

        <div style={{ marginBottom: 'var(--spacing-24)' }}>
          <Link to="/design-system" style={{
            display: 'inline-block',
            padding: '8px 16px',
            background: 'var(--surface)',
            border: '1px solid var(--border)',
            borderRadius: 'var(--radius-8)',
            color: 'var(--text-primary)',
            textDecoration: 'none',
            marginRight: 'var(--spacing-8)'
          }}>
            00_DesignSystem
          </Link>
          <Link to="/screens" style={{
            display: 'inline-block',
            padding: '8px 16px',
            background: 'var(--surface)',
            border: '1px solid var(--border)',
            borderRadius: 'var(--radius-8)',
            color: 'var(--text-primary)',
            textDecoration: 'none'
          }}>
            01_Screens
          </Link>
        </div>

        <div style={{
          display: 'flex',
          flexDirection: 'column',
          gap: 'var(--spacing-24)'
        }}>
          {journeys.map((journey) => (
            <div key={journey.id} style={{
              background: 'var(--surface)',
              padding: 'var(--spacing-24)',
              borderRadius: 'var(--radius-16)',
              border: '1px solid var(--border)',
              boxShadow: 'var(--elevation-1)'
            }}>
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <p className="text-caption">{journey.id}</p>
                <h2 className="text-h2" style={{ marginTop: 'var(--spacing-4)' }}>
                  {journey.name}
                </h2>
              </div>

              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 'var(--spacing-12)',
                overflowX: 'auto',
                paddingBottom: 'var(--spacing-8)'
              }}>
                {journey.steps.map((step, index) => (
                  <div key={index} style={{ display: 'flex', alignItems: 'center', gap: 'var(--spacing-12)' }}>
                    <Link
                      to={step.path}
                      style={{
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        gap: 'var(--spacing-8)',
                        padding: 'var(--spacing-12)',
                        background: 'var(--surface-alt)',
                        border: '1px solid var(--border)',
                        borderRadius: 'var(--radius-12)',
                        textDecoration: 'none',
                        minWidth: '120px',
                        transition: 'all 0.2s'
                      }}
                    >
                      <div style={{
                        width: '80px',
                        height: '160px',
                        background: 'var(--bg)',
                        borderRadius: 'var(--radius-8)',
                        border: '2px solid var(--border)',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center'
                      }}>
                        <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>
                          {step.screen}
                        </span>
                      </div>
                      <span className="text-caption" style={{
                        textAlign: 'center',
                        color: 'var(--text-primary)'
                      }}>
                        {step.name}
                      </span>
                    </Link>
                    {index < journey.steps.length - 1 && (
                      <ArrowRight size={20} style={{ color: 'var(--text-tertiary)' }} />
                    )}
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        {/* Prototype Links Reference */}
        <div style={{
          marginTop: 'var(--spacing-32)',
          background: 'var(--surface)',
          padding: 'var(--spacing-24)',
          borderRadius: 'var(--radius-16)',
          border: '1px solid var(--border)'
        }}>
          <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-16)' }}>
            Prototype Link Rules
          </h3>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
            gap: 'var(--spacing-12)'
          }}>
            {[
              'BottomNav: SCR-004 ↔ SCR-005 ↔ SCR-009',
              'SCR-004: tap account → SCR-007',
              'SCR-004: tap currency → SCR-012',
              'SCR-005: Add account → SCR-006',
              'SCR-005: tap row → SCR-007',
              'SCR-007: Add asset → SCR-008',
              'SCR-007: tap asset → SCR-010',
              'SCR-010: Add balance → SCR-011',
              'SCR-009: Base currency → SCR-012',
              'SCR-009: Manage sub → SCR-014',
              'SCR-012: locked → SCR-013',
              'SCR-013: Not now → return',
            ].map((rule, index) => (
              <p key={index} className="text-caption" style={{
                padding: 'var(--spacing-8)',
                background: 'var(--surface-alt)',
                borderRadius: 'var(--radius-8)'
              }}>
                {rule}
              </p>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
