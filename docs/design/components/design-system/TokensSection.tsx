export function TokensSection() {
  const spacings = [4, 8, 12, 16, 24, 32];
  const radii = [8, 12, 16];
  
  const colors = {
    primary: [
      { name: 'primary', value: '#2563EB' },
      { name: 'primaryHover', value: '#1D4ED8' },
      { name: 'onPrimary', value: '#FFFFFF' },
    ],
    background: [
      { name: 'bg', value: '#F8FAFC' },
      { name: 'surface', value: '#FFFFFF' },
      { name: 'surfaceAlt', value: '#F1F5F9' },
    ],
    text: [
      { name: 'textPrimary', value: '#0F172A' },
      { name: 'textSecondary', value: '#64748B' },
      { name: 'textTertiary', value: '#94A3B8' },
      { name: 'textOnPrimary', value: '#FFFFFF' },
    ],
    border: [
      { name: 'border', value: '#E2E8F0' },
    ],
    semantic: [
      { name: 'success', value: '#16A34A' },
      { name: 'warning', value: '#F59E0B' },
      { name: 'danger', value: '#DC2626' },
      { name: 'info', value: '#0EA5E9' },
    ],
    neutrals: [
      { name: 'neutral-0', value: '#FFFFFF' },
      { name: 'neutral-50', value: '#F8FAFC' },
      { name: 'neutral-100', value: '#F1F5F9' },
      { name: 'neutral-200', value: '#E2E8F0' },
      { name: 'neutral-300', value: '#CBD5E1' },
      { name: 'neutral-400', value: '#94A3B8' },
      { name: 'neutral-500', value: '#64748B' },
      { name: 'neutral-600', value: '#334155' },
      { name: 'neutral-900', value: '#0F172A' },
    ],
  };

  return (
    <section style={{ marginBottom: 'var(--spacing-32)' }}>
      <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-16)' }}>
        Tokens
      </h2>

      {/* Spacing */}
      <div style={{ marginBottom: 'var(--spacing-24)' }}>
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
          Spacing
        </h3>
        <div style={{ 
          display: 'flex',
          flexDirection: 'column',
          gap: 'var(--spacing-8)'
        }}>
          {spacings.map((size) => (
            <div key={size} style={{ display: 'flex', alignItems: 'center', gap: 'var(--spacing-12)' }}>
              <span className="text-caption" style={{ width: '40px' }}>{size}px</span>
              <div style={{
                width: `${size}px`,
                height: '24px',
                background: 'var(--primary)',
                borderRadius: 'var(--radius-8)'
              }} />
            </div>
          ))}
        </div>
      </div>

      {/* Radius */}
      <div style={{ marginBottom: 'var(--spacing-24)' }}>
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
          Radius
        </h3>
        <div style={{ 
          display: 'flex',
          gap: 'var(--spacing-12)'
        }}>
          {radii.map((size) => (
            <div key={size} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--spacing-8)' }}>
              <div style={{
                width: '48px',
                height: '48px',
                background: 'var(--primary)',
                borderRadius: `${size}px`
              }} />
              <span className="text-caption">{size}px</span>
            </div>
          ))}
        </div>
      </div>

      {/* Elevation */}
      <div style={{ marginBottom: 'var(--spacing-24)' }}>
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
          Elevation
        </h3>
        <div style={{ 
          display: 'flex',
          gap: 'var(--spacing-12)'
        }}>
          {[
            { name: 'e0', shadow: 'none' },
            { name: 'e1', shadow: '0 1px 2px 0 rgba(0, 0, 0, 0.05)' },
            { name: 'e2', shadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)' },
          ].map((elev) => (
            <div key={elev.name} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 'var(--spacing-8)' }}>
              <div style={{
                width: '64px',
                height: '64px',
                background: 'var(--surface)',
                borderRadius: 'var(--radius-12)',
                boxShadow: elev.shadow
              }} />
              <span className="text-caption">{elev.name}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Colors */}
      <div>
        <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
          Colors
        </h3>
        
        {Object.entries(colors).map(([category, colorList]) => (
          <div key={category} style={{ marginBottom: 'var(--spacing-16)' }}>
            <p className="text-caption" style={{ 
              marginBottom: 'var(--spacing-8)',
              textTransform: 'capitalize'
            }}>
              {category}
            </p>
            <div style={{ 
              display: 'flex',
              flexWrap: 'wrap',
              gap: 'var(--spacing-8)'
            }}>
              {colorList.map((color) => (
                <div key={color.name} style={{ 
                  display: 'flex',
                  flexDirection: 'column',
                  gap: 'var(--spacing-4)',
                  minWidth: category === 'neutrals' ? '72px' : '100px'
                }}>
                  <div style={{
                    width: '100%',
                    height: '40px',
                    background: color.value,
                    borderRadius: 'var(--radius-8)',
                    border: color.value === '#FFFFFF' ? '1px solid var(--border)' : 'none'
                  }} />
                  <span className="text-caption" style={{ fontSize: '11px' }}>{color.name}</span>
                </div>
              ))}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
