interface TextFieldProps {
  label: string;
  placeholder?: string;
  helper?: string;
  error?: string;
  disabled?: boolean;
}

export function TextField({ label, placeholder, helper, error, disabled }: TextFieldProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-8)' }}>
      <label className="text-caption" style={{ color: 'var(--text-primary)', fontWeight: 600 }}>
        {label}
      </label>
      <input
        type="text"
        placeholder={placeholder}
        disabled={disabled}
        style={{
          padding: '14px var(--spacing-16)',
          borderRadius: 'var(--radius-12)',
          border: `1.5px solid ${error ? 'var(--danger)' : 'var(--border)'}`,
          background: disabled ? 'var(--surface-alt)' : 'var(--surface)',
          color: 'var(--text-primary)',
          fontSize: '16px',
          lineHeight: '24px',
          outline: 'none',
          cursor: disabled ? 'not-allowed' : 'text',
          opacity: disabled ? 0.6 : 1,
          transition: 'border-color 0.2s, box-shadow 0.2s',
          boxShadow: error ? '0 0 0 3px rgba(220, 38, 38, 0.1)' : 'none'
        }}
        onFocus={(e) => {
          if (!error && !disabled) {
            e.target.style.borderColor = 'var(--primary)';
            e.target.style.boxShadow = '0 0 0 3px rgba(37, 99, 235, 0.1)';
          }
        }}
        onBlur={(e) => {
          if (!error) {
            e.target.style.borderColor = 'var(--border)';
            e.target.style.boxShadow = 'none';
          }
        }}
      />
      {(helper || error) && (
        <span className="text-caption" style={{ color: error ? 'var(--danger)' : 'var(--text-secondary)' }}>
          {error || helper}
        </span>
      )}
    </div>
  );
}