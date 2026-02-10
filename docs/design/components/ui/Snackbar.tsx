import { CheckCircle, AlertCircle, Info } from 'lucide-react';

interface SnackbarProps {
  variant: 'success' | 'error' | 'info';
  message: string;
}

export function Snackbar({ variant, message }: SnackbarProps) {
  const config = {
    success: {
      icon: CheckCircle,
      bg: 'var(--success)',
      color: '#FFFFFF'
    },
    error: {
      icon: AlertCircle,
      bg: 'var(--danger)',
      color: '#FFFFFF'
    },
    info: {
      icon: Info,
      bg: 'var(--text-primary)',
      color: '#FFFFFF'
    }
  };

  const { icon: Icon, bg, color } = config[variant];

  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      gap: 'var(--spacing-12)',
      padding: 'var(--spacing-12) var(--spacing-16)',
      background: bg,
      color: color,
      borderRadius: 'var(--radius-12)',
      boxShadow: 'var(--elevation-2)',
      maxWidth: '320px'
    }}>
      <Icon size={20} />
      <span className="text-body" style={{ color }}>{message}</span>
    </div>
  );
}
