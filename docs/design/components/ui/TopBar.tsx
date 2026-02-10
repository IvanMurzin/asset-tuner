import { ArrowLeft } from 'lucide-react';

interface TopBarProps {
  title: string;
  showBack?: boolean;
  trailingIcon?: React.ReactNode;
}

export function TopBar({ title, showBack, trailingIcon }: TopBarProps) {
  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      height: '56px',
      padding: '0 var(--spacing-16)',
      background: 'var(--surface)',
      borderBottom: '1px solid var(--border)'
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 'var(--spacing-12)' }}>
        {showBack && (
          <button style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '40px',
            height: '40px',
            background: 'transparent',
            border: 'none',
            cursor: 'pointer',
            borderRadius: 'var(--radius-8)',
            color: 'var(--text-primary)'
          }}>
            <ArrowLeft size={20} />
          </button>
        )}
        <h3 className="text-h3">{title}</h3>
      </div>
      {trailingIcon && (
        <button style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          width: '40px',
          height: '40px',
          background: 'transparent',
          border: 'none',
          cursor: 'pointer',
          borderRadius: 'var(--radius-8)',
          color: 'var(--text-primary)'
        }}>
          {trailingIcon}
        </button>
      )}
    </div>
  );
}
