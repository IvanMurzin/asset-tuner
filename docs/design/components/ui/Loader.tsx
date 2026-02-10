import { Loader2 } from 'lucide-react';

interface LoaderProps {
  fullScreen?: boolean;
}

export function Loader({ fullScreen = true }: LoaderProps) {
  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      width: '100%',
      height: fullScreen ? '100vh' : '100%',
      background: fullScreen ? 'var(--bg)' : 'transparent'
    }}>
      <Loader2 
        size={32} 
        style={{ 
          color: 'var(--primary)',
          animation: 'spin 1s linear infinite'
        }} 
      />
      <style>{`
        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
