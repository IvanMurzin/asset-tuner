import { ScreenWrapper } from './ScreenWrapper';
import { TextField } from '../ui/TextField';
import { Button } from '../ui/Button';
import { Banner } from '../ui/Banner';
import { Mail } from 'lucide-react';

export function SignInScreen() {
  return (
    <ScreenWrapper screenId="002" screenName="Sign-in">
      {(state) => (
        <div style={{
          height: '844px',
          display: 'flex',
          flexDirection: 'column',
          background: 'var(--bg)'
        }}>
          {/* Header with gradient */}
          <div style={{
            padding: 'var(--spacing-32) var(--spacing-24)',
            background: 'linear-gradient(135deg, var(--primary) 0%, #1E40AF 100%)',
            borderBottomLeftRadius: 'var(--radius-24)',
            borderBottomRightRadius: 'var(--radius-24)'
          }}>
            <h1 className="text-h1" style={{ color: 'var(--surface)', marginBottom: 'var(--spacing-8)' }}>
              Welcome back
            </h1>
            <p className="text-body" style={{ color: 'rgba(255, 255, 255, 0.9)' }}>
              Sign in to manage your portfolio
            </p>
          </div>

          <div style={{
            flex: 1,
            padding: 'var(--spacing-24)',
            display: 'flex',
            flexDirection: 'column'
          }}>
            {state === 'error' && (
              <div style={{ marginBottom: 'var(--spacing-16)' }}>
                <Banner variant="error" message="Failed to send code" />
              </div>
            )}

            <div style={{ marginBottom: 'var(--spacing-24)' }}>
              <TextField
                label="Email"
                placeholder="name@example.com"
                helper="We'll send you a one-time code"
                disabled={state === 'loading'}
              />
            </div>

            <Button
              variant="primary"
              loading={state === 'loading'}
              disabled={state === 'loading'}
            >
              Send code
            </Button>

            <div style={{
              display: 'flex',
              alignItems: 'center',
              gap: 'var(--spacing-16)',
              margin: 'var(--spacing-32) 0'
            }}>
              <div style={{ flex: 1, height: '1px', background: 'var(--border)' }} />
              <span className="text-caption" style={{ color: 'var(--text-tertiary)' }}>or continue with</span>
              <div style={{ flex: 1, height: '1px', background: 'var(--border)' }} />
            </div>

            <div style={{
              display: 'flex',
              flexDirection: 'column',
              gap: 'var(--spacing-12)'
            }}>
              <Button variant="secondary" disabled={state === 'loading'}>
                <svg width="18" height="18" viewBox="0 0 18 18" style={{ marginRight: '8px' }}>
                  <path fill="#4285F4" d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.874 2.684-6.615z"/>
                  <path fill="#34A853" d="M9 18c2.43 0 4.467-.806 5.956-2.184l-2.908-2.258c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332C2.438 15.983 5.482 18 9 18z"/>
                  <path fill="#FBBC05" d="M3.964 10.707c-.18-.54-.282-1.117-.282-1.707s.102-1.167.282-1.707V4.961H.957C.347 6.175 0 7.55 0 9s.348 2.825.957 4.039l3.007-2.332z"/>
                  <path fill="#EA4335" d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0 5.482 0 2.438 2.017.957 4.961L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z"/>
                </svg>
                Continue with Google
              </Button>
              <Button variant="secondary" disabled={state === 'loading'}>
                <svg width="18" height="18" viewBox="0 0 18 18" fill="currentColor" style={{ marginRight: '8px' }}>
                  <path d="M14.907 5.282c-.136.996-.806 2.037-1.787 2.914-.982.878-2.318 1.515-3.989 1.515-1.563 0-2.783-.498-3.607-1.338C4.7 7.533 4.238 6.36 4.238 4.968c0-1.01.216-1.857.616-2.573C5.254 1.68 5.9 1.15 6.704.833c.804-.318 1.707-.476 2.706-.476.999 0 1.892.172 2.678.513.785.341 1.414.826 1.886 1.453l-1.49 1.415c-.34-.451-.758-.79-1.253-1.016-.495-.226-1.053-.339-1.673-.339-.808 0-1.485.267-2.033.801-.547.535-.82 1.274-.82 2.218 0 .944.273 1.683.82 2.218.548.534 1.225.801 2.033.801.899 0 1.642-.233 2.228-.698.586-.465.952-1.097 1.098-1.896h-3.326V4.181h5.35z"/>
                </svg>
                Continue with Apple
              </Button>
            </div>

            {state === 'empty' && (
              <div style={{ marginTop: 'var(--spacing-24)' }}>
                <p className="text-caption" style={{ textAlign: 'center', color: 'var(--text-tertiary)' }}>
                  No empty state
                </p>
              </div>
            )}
          </div>
        </div>
      )}
    </ScreenWrapper>
  );
}