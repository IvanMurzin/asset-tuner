interface SegmentedControlProps {
  value: 'snapshot' | 'change';
  onChange: (value: 'snapshot' | 'change') => void;
}

export function SegmentedControl({ value, onChange }: SegmentedControlProps) {
  return (
    <div style={{
      display: 'flex',
      background: 'var(--surface-alt)',
      borderRadius: 'var(--radius-12)',
      padding: 'var(--spacing-4)',
      gap: 'var(--spacing-4)'
    }}>
      {(['snapshot', 'change'] as const).map((option) => (
        <button
          key={option}
          onClick={() => onChange(option)}
          style={{
            flex: 1,
            padding: '8px 16px',
            borderRadius: 'var(--radius-8)',
            border: 'none',
            background: value === option ? 'var(--surface)' : 'transparent',
            color: value === option ? 'var(--text-primary)' : 'var(--text-secondary)',
            fontSize: '14px',
            fontWeight: value === option ? 600 : 400,
            cursor: 'pointer',
            transition: 'all 0.2s',
            boxShadow: value === option ? 'var(--elevation-1)' : 'none',
            textTransform: 'capitalize'
          }}
        >
          {option}
        </button>
      ))}
    </div>
  );
}
