import { useState } from 'react';
import { Link } from 'react-router';
import { ArrowLeft } from 'lucide-react';

interface ScreenWrapperProps {
  screenId: string;
  screenName: string;
  children: (state: 'default' | 'loading' | 'empty' | 'error') => React.ReactNode;
}

export function ScreenWrapper({ screenId, screenName, children }: ScreenWrapperProps) {
  const [currentState, setCurrentState] = useState<'default' | 'loading' | 'empty' | 'error'>('default');

  return (
    <div className="min-h-screen" style={{ background: 'var(--bg)' }}>
      {/* Navigation */}
      <div style={{
        background: 'var(--surface)',
        borderBottom: '1px solid var(--border)',
        padding: 'var(--spacing-16)'
      }}>
        <Link to="/screens" style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: 'var(--spacing-8)',
          color: 'var(--text-primary)',
          textDecoration: 'none',
          marginBottom: 'var(--spacing-12)'
        }}>
          <ArrowLeft size={20} />
          <span className="text-body">Back to Screens</span>
        </Link>
        <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-4)' }}>
          SCR-{screenId} {screenName}
        </h2>
        
        {/* State Selector */}
        <div style={{
          display: 'flex',
          gap: 'var(--spacing-8)',
          marginTop: 'var(--spacing-12)',
          flexWrap: 'wrap'
        }}>
          {(['default', 'loading', 'empty', 'error'] as const).map((state) => (
            <button
              key={state}
              onClick={() => setCurrentState(state)}
              style={{
                padding: '6px 12px',
                borderRadius: 'var(--radius-8)',
                border: '1px solid var(--border)',
                background: currentState === state ? 'var(--primary)' : 'var(--surface)',
                color: currentState === state ? 'var(--on-primary)' : 'var(--text-primary)',
                fontSize: '13px',
                fontWeight: 500,
                cursor: 'pointer',
                textTransform: 'capitalize'
              }}
            >
              {state}
            </button>
          ))}
        </div>
      </div>

      {/* Screen Frame */}
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        padding: 'var(--spacing-24)',
        minHeight: 'calc(100vh - 180px)'
      }}>
        <div style={{
          width: '390px',
          minHeight: '844px',
          background: 'var(--surface)',
          borderRadius: 'var(--radius-16)',
          boxShadow: 'var(--elevation-2)',
          overflow: 'hidden',
          position: 'relative'
        }}>
          {children(currentState)}
        </div>
      </div>

      {/* State Label */}
      <div style={{
        position: 'fixed',
        bottom: 'var(--spacing-16)',
        right: 'var(--spacing-16)',
        padding: '8px 16px',
        background: 'var(--text-primary)',
        color: 'var(--on-primary)',
        borderRadius: 'var(--radius-8)',
        fontSize: '13px',
        fontWeight: 500,
        textTransform: 'capitalize'
      }}>
        {currentState}
      </div>
    </div>
  );
}
