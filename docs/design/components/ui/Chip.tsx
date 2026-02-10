interface ChipProps {
  variant: 'neutral' | 'primary';
  children: React.ReactNode;
}

export function Chip({ variant, children }: ChipProps) {
  const getStyles = () => {
    const base = {
      display: 'inline-flex',
      alignItems: 'center',
      padding: '6px 12px',
      borderRadius: 'var(--radius-8)',
      fontSize: '13px',
      fontWeight: 500,
      lineHeight: '18px'
    };

    if (variant === 'primary') {
      return {
        ...base,
        background: 'var(--primary)',
        color: 'var(--on-primary)'
      };
    }

    return {
      ...base,
      background: 'var(--surface-alt)',
      color: 'var(--text-primary)',
      border: '1px solid var(--border)'
    };
  };

  return <div style={getStyles()}>{children}</div>;
}
