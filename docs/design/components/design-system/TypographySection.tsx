export function TypographySection() {
  const styles = [
    { name: 'H1', className: 'text-h1', desc: '28/34 Semibold' },
    { name: 'H2', className: 'text-h2', desc: '20/26 Semibold' },
    { name: 'H3', className: 'text-h3', desc: '16/22 Semibold' },
    { name: 'Body', className: 'text-body', desc: '16/24 Regular' },
    { name: 'Caption', className: 'text-caption', desc: '13/18 Regular' },
    { name: 'Total Numeric', className: 'text-total-numeric', desc: '34/40 Semibold (tabular)' },
  ];

  return (
    <section style={{ marginBottom: 'var(--spacing-32)' }}>
      <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-16)' }}>
        Typography
      </h2>

      <div style={{ 
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--spacing-16)'
      }}>
        {styles.map((style) => (
          <div key={style.name} style={{
            background: 'var(--surface)',
            padding: 'var(--spacing-16)',
            borderRadius: 'var(--radius-12)',
            border: '1px solid var(--border)'
          }}>
            <p className="text-caption" style={{ marginBottom: 'var(--spacing-8)' }}>
              {style.name} · {style.desc}
            </p>
            <div className={style.className}>
              {style.name === 'Total Numeric' ? '1,234,567.89' : 'Sample Text'}
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
