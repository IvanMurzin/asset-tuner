import { Info, AlertTriangle, AlertCircle } from 'lucide-react';

interface BannerProps {
  variant: 'info' | 'warning' | 'error';
  message: string;
}

export function Banner({ variant, message }: BannerProps) {
  const config = {
    info: {
      icon: Info,
      bg: 'var(--info)',
      color: '#FFFFFF'
    },
    warning: {
      icon: AlertTriangle,
      bg: 'var(--warning)',
      color: '#FFFFFF'
    },
    error: {
      icon: AlertCircle,
      bg: 'var(--danger)',
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
      borderRadius: 'var(--radius-12)'
    }}>
      <Icon size={20} />
      <span className="text-body" style={{ color, flex: 1 }}>{message}</span>
    </div>
  );
}
