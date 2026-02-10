import { ChevronRight } from 'lucide-react';

interface ListRowProps {
  icon?: React.ReactNode;
  title: string;
  subtitle?: string;
  value?: string;
  showChevron?: boolean;
  variant?: 'default' | 'selected' | 'disabled';
}

export function ListRow({ icon, title, subtitle, value, showChevron, variant = 'default' }: ListRowProps) {
  const getBackgroundColor = () => {
    if (variant === 'selected') return 'var(--surface-alt)';
    return 'transparent';
  };

  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--spacing-12)',
      padding: 'var(--spacing-16)',
      background: getBackgroundColor(),
      cursor: variant === 'disabled' ? 'not-allowed' : 'pointer',
      opacity: variant === 'disabled' ? 0.5 : 1,
      transition: 'background 0.2s'
    }}>
      {icon && (
        <div style={{ 
          width: '40px',
          height: '40px',
          borderRadius: 'var(--radius-8)',
          background: variant === 'selected' ? 'var(--primary)' : 'var(--surface-alt)',
          color: variant === 'selected' ? 'var(--on-primary)' : 'var(--text-secondary)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0
        }}>
          {icon}
        </div>
      )}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 'var(--spacing-4)', minWidth: 0 }}>
        <span className="text-body" style={{ fontWeight: 500 }}>{title}</span>
        {subtitle && <span className="text-caption">{subtitle}</span>}
      </div>
      {value && (
        <span className="text-body" style={{ fontWeight: 600, fontVariantNumeric: 'tabular-nums', flexShrink: 0 }}>
          {value}
        </span>
      )}
      {showChevron && (
        <ChevronRight size={20} style={{ color: 'var(--text-tertiary)', flexShrink: 0 }} />
      )}
    </div>
  );
}