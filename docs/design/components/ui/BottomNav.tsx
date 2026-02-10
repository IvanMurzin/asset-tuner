import { LayoutGrid, CreditCard, Settings } from 'lucide-react';

interface BottomNavProps {
  activeTab: number;
  onTabChange: (index: number) => void;
}

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  const tabs = [
    { icon: LayoutGrid, label: 'Overview' },
    { icon: CreditCard, label: 'Accounts' },
    { icon: Settings, label: 'Settings' },
  ];

  return (
    <div style={{
      display: 'flex',
      height: '72px',
      background: 'var(--surface)',
      borderTop: '1px solid var(--border)',
      boxShadow: '0 -2px 8px rgba(0, 0, 0, 0.04)',
      paddingBottom: 'env(safe-area-inset-bottom)'
    }}>
      {tabs.map((tab, index) => {
        const Icon = tab.icon;
        const isActive = activeTab === index;
        
        return (
          <button
            key={tab.label}
            onClick={() => onTabChange(index)}
            style={{
              flex: 1,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              gap: 'var(--spacing-4)',
              background: 'transparent',
              border: 'none',
              cursor: 'pointer',
              color: isActive ? 'var(--primary)' : 'var(--text-tertiary)',
              transition: 'color 0.2s',
              position: 'relative'
            }}
          >
            {isActive && (
              <div style={{
                position: 'absolute',
                top: 0,
                left: '50%',
                transform: 'translateX(-50%)',
                width: '32px',
                height: '3px',
                background: 'var(--primary)',
                borderRadius: '0 0 3px 3px'
              }} />
            )}
            <Icon size={22} strokeWidth={isActive ? 2.5 : 2} />
            <span style={{
              fontSize: '11px',
              lineHeight: '14px',
              fontWeight: isActive ? 600 : 500
            }}>
              {tab.label}
            </span>
          </button>
        );
      })}
    </div>
  );
}