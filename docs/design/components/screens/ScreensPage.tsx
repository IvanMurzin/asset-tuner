import { Link } from 'react-router';

export function ScreensPage() {
  const screens = [
    { id: '001', name: 'Splash / Session restore', path: '/splash' },
    { id: '002', name: 'Sign-in', path: '/sign-in' },
    { id: '003', name: 'Onboarding: Base currency', path: '/onboarding-currency' },
    { id: '004', name: 'Overview', path: '/overview' },
    { id: '005', name: 'Accounts list', path: '/accounts' },
    { id: '006', name: 'Account form', path: '/account-form' },
    { id: '007', name: 'Account detail', path: '/account-detail' },
    { id: '008', name: 'Add asset', path: '/add-asset' },
    { id: '009', name: 'Settings', path: '/settings' },
    { id: '010', name: 'Asset position detail', path: '/asset-detail' },
    { id: '011', name: 'Add balance', path: '/add-balance' },
    { id: '012', name: 'Base currency settings', path: '/base-currency-settings' },
    { id: '013', name: 'Paywall', path: '/paywall' },
    { id: '014', name: 'Manage subscription', path: '/manage-subscription' },
  ];

  return (
    <div className="min-h-screen" style={{ 
      background: 'var(--bg)',
      padding: 'var(--spacing-16)'
    }}>
      <div style={{ maxWidth: '800px', margin: '0 auto' }}>
        <div style={{ marginBottom: 'var(--spacing-24)' }}>
          <h1 className="text-h1">Asset Tuner</h1>
          <p className="text-caption" style={{ marginTop: 'var(--spacing-4)' }}>
            01_Screens — MVP Screens
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
          <Link to="/flows" style={{
            display: 'inline-block',
            padding: '8px 16px',
            background: 'var(--surface)',
            border: '1px solid var(--border)',
            borderRadius: 'var(--radius-8)',
            color: 'var(--text-primary)',
            textDecoration: 'none'
          }}>
            02_Flows
          </Link>
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))',
          gap: 'var(--spacing-16)'
        }}>
          {screens.map((screen) => (
            <Link
              key={screen.id}
              to={screen.path}
              style={{
                display: 'block',
                padding: 'var(--spacing-16)',
                background: 'var(--surface)',
                border: '1px solid var(--border)',
                borderRadius: 'var(--radius-12)',
                textDecoration: 'none',
                transition: 'all 0.2s',
                boxShadow: 'var(--elevation-1)'
              }}
            >
              <div className="text-caption" style={{ marginBottom: 'var(--spacing-4)' }}>
                SCR-{screen.id}
              </div>
              <div className="text-h3">{screen.name}</div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
