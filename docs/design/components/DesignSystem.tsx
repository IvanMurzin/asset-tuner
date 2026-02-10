import { TokensSection } from './design-system/TokensSection';
import { TypographySection } from './design-system/TypographySection';
import { ComponentsSection } from './design-system/ComponentsSection';

export function DesignSystem() {
  return (
    <div className="min-h-screen" style={{ 
      background: 'var(--bg)',
      maxWidth: '390px',
      margin: '0 auto'
    }}>
      {/* Header */}
      <div style={{
        background: 'var(--surface)',
        borderBottom: '1px solid var(--border)',
        padding: 'var(--spacing-16)'
      }}>
        <h1 className="text-h1">Asset Tuner</h1>
        <p className="text-caption" style={{ marginTop: 'var(--spacing-4)' }}>
          Design System
        </p>
      </div>

      {/* Content */}
      <div style={{ padding: 'var(--spacing-16)' }}>
        <TokensSection />
        <TypographySection />
        <ComponentsSection />
      </div>
    </div>
  );
}
