import { ScreenWrapper } from './ScreenWrapper';
import { Loader } from '../ui/Loader';
import { StateBlock } from '../ui/StateBlock';
import { Button } from '../ui/Button';
import { AlertCircle } from 'lucide-react';

export function SplashScreen() {
  return (
    <ScreenWrapper screenId="001" screenName="Splash / Session restore">
      {(state) => {
        if (state === 'error') {
          return (
            <div style={{
              height: '844px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              background: 'linear-gradient(to bottom, var(--bg), var(--surface))'
            }}>
              <StateBlock
                variant="error"
                icon={<AlertCircle size={48} />}
                title="Connection failed"
                message="Unable to restore session"
                action={<Button variant="primary">Try again</Button>}
              />
            </div>
          );
        }

        return (
          <div style={{
            height: '844px',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            background: 'linear-gradient(135deg, var(--primary) 0%, #1E40AF 100%)',
            gap: 'var(--spacing-32)'
          }}>
            <div style={{
              width: '96px',
              height: '96px',
              borderRadius: 'var(--radius-16)',
              background: 'var(--surface)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              boxShadow: '0 20px 40px rgba(0, 0, 0, 0.3)'
            }}>
              <span style={{
                fontSize: '48px',
                fontWeight: 700,
                background: 'linear-gradient(135deg, var(--primary), #1E40AF)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text'
              }}>
                AT
              </span>
            </div>
            
            {state !== 'empty' && (
              <>
                <div style={{ marginTop: 'var(--spacing-16)' }}>
                  <Loader fullScreen={false} />
                </div>
                <p className="text-body" style={{ color: 'var(--surface)', fontWeight: 500 }}>
                  {state === 'loading' ? 'Restoring session...' : 'Loading...'}
                </p>
              </>
            )}
            
            {state === 'empty' && (
              <p className="text-body" style={{ color: 'var(--surface)', fontWeight: 500 }}>
                Ready to launch
              </p>
            )}
          </div>
        );
      }}
    </ScreenWrapper>
  );
}