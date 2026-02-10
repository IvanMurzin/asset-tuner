import { Calendar } from 'lucide-react';

interface DateFieldProps {
  label: string;
  value: string;
}

export function DateField({ label, value }: DateFieldProps) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-8)' }}>
      <label className="text-caption" style={{ color: 'var(--text-primary)', fontWeight: 500 }}>
        {label}
      </label>
      <button style={{
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        padding: '12px var(--spacing-16)',
        borderRadius: 'var(--radius-12)',
        border: '1px solid var(--border)',
        background: 'var(--surface)',
        color: 'var(--text-primary)',
        fontSize: '16px',
        lineHeight: '24px',
        cursor: 'pointer',
        textAlign: 'left'
      }}>
        <span>{value}</span>
        <Calendar size={20} style={{ color: 'var(--text-tertiary)' }} />
      </button>
    </div>
  );
}
