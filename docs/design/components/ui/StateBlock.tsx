interface StateBlockProps {
  variant: 'empty' | 'error';
  icon: React.ReactNode;
  title: string;
  message: string;
  action?: React.ReactNode;
}

export function StateBlock({ icon, title, message, action }: StateBlockProps) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 'var(--spacing-48) var(--spacing-24)',
      textAlign: 'center',
      gap: 'var(--spacing-20)'
    }}>
      <div style={{
        width: '96px',
        height: '96px',
        borderRadius: '50%',
        background: 'var(--surface-alt)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'var(--text-tertiary)'
      }}>
        {icon}
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-8)', maxWidth: '280px' }}>
        <h3 className="text-h3">{title}</h3>
        <p className="text-body" style={{ color: 'var(--text-secondary)' }}>{message}</p>
      </div>
      {action && <div>{action}</div>}
    </div>
  );
}