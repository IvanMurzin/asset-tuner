interface AmountFieldProps {
  label: string;
  value: string;
}

export function AmountField({ label, value }: AmountFieldProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-8)' }}>
      <label className="text-caption" style={{ color: 'var(--text-primary)', fontWeight: 500 }}>
        {label}
      </label>
      <input
        type="text"
        value={value}
        readOnly
        style={{
          padding: '12px var(--spacing-16)',
          borderRadius: 'var(--radius-12)',
          border: '1px solid var(--border)',
          background: 'var(--surface)',
          color: 'var(--text-primary)',
          fontSize: '24px',
          lineHeight: '32px',
          fontWeight: 600,
          fontVariantNumeric: 'tabular-nums',
          outline: 'none',
          textAlign: 'right'
        }}
      />
    </div>
  );
}
