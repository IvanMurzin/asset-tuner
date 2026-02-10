import { TopBar } from '../ui/TopBar';
import { BottomNav } from '../ui/BottomNav';
import { Button } from '../ui/Button';
import { TextField } from '../ui/TextField';
import { Card } from '../ui/Card';
import { ListRow } from '../ui/ListRow';
import { Chip } from '../ui/Chip';
import { Badge } from '../ui/Badge';
import { Banner } from '../ui/Banner';
import { StateBlock } from '../ui/StateBlock';
import { Loader } from '../ui/Loader';
import { Skeleton } from '../ui/Skeleton';
import { Dialog } from '../ui/Dialog';
import { Snackbar } from '../ui/Snackbar';
import { SegmentedControl } from '../ui/SegmentedControl';
import { DateField } from '../ui/DateField';
import { AmountField } from '../ui/AmountField';
import { Home, Settings, CreditCard, AlertCircle, CheckCircle, Info, TrendingUp } from 'lucide-react';
import { useState } from 'react';

export function ComponentsSection() {
  const [selectedTab, setSelectedTab] = useState(0);
  const [segmentValue, setSegmentValue] = useState<'snapshot' | 'change'>('snapshot');

  return (
    <section style={{ marginBottom: 'var(--spacing-32)' }}>
      <h2 className="text-h2" style={{ marginBottom: 'var(--spacing-16)' }}>
        Components
      </h2>

      {/* TopBar */}
      <ComponentShowcase title="TopBar / AppBar">
        <TopBar title="Dashboard" />
        <TopBar title="Details" showBack />
        <TopBar title="Settings" showBack trailingIcon={<Settings size={20} />} />
      </ComponentShowcase>

      {/* BottomNav */}
      <ComponentShowcase title="Bottom Navigation">
        <div style={{ marginBottom: 'var(--spacing-8)' }}>
          <BottomNav activeTab={0} onTabChange={setSelectedTab} />
        </div>
        <BottomNav activeTab={1} onTabChange={setSelectedTab} />
      </ComponentShowcase>

      {/* Buttons */}
      <ComponentShowcase title="Button">
        <div style={{ display: 'flex', flexDirection: 'column', gap: 'var(--spacing-8)' }}>
          <div style={{ display: 'flex', gap: 'var(--spacing-8)' }}>
            <Button variant="primary">Primary</Button>
            <Button variant="secondary">Secondary</Button>
            <Button variant="tertiary">Tertiary</Button>
          </div>
          <div style={{ display: 'flex', gap: 'var(--spacing-8)' }}>
            <Button variant="primary" disabled>Disabled</Button>
            <Button variant="primary" loading>Loading</Button>
          </div>
        </div>
      </ComponentShowcase>

      {/* TextField */}
      <ComponentShowcase title="Text Field">
        <TextField label="Email" placeholder="name@example.com" helper="Enter your email" />
        <TextField label="Password" placeholder="••••••••" error="Password is required" />
        <TextField label="Name" placeholder="John Doe" disabled />
      </ComponentShowcase>

      {/* Card */}
      <ComponentShowcase title="Card">
        <Card>
          <p className="text-body">Card content goes here</p>
        </Card>
        <Card header="Account Summary">
          <p className="text-body">Card with header</p>
        </Card>
      </ComponentShowcase>

      {/* ListRow */}
      <ComponentShowcase title="List Row">
        <ListRow 
          icon={<CreditCard size={20} />}
          title="Checking Account"
          subtitle="••••1234"
          value="$12,345.67"
        />
        <ListRow 
          icon={<TrendingUp size={20} />}
          title="Investments"
          subtitle="Portfolio"
          showChevron
        />
        <ListRow 
          icon={<Settings size={20} />}
          title="Settings"
          variant="selected"
          showChevron
        />
        <ListRow 
          icon={<AlertCircle size={20} />}
          title="Disabled Item"
          variant="disabled"
        />
      </ComponentShowcase>

      {/* Chip & Badge */}
      <ComponentShowcase title="Chip / Tag & Badge">
        <div style={{ display: 'flex', gap: 'var(--spacing-8)', flexWrap: 'wrap' }}>
          <Chip variant="neutral">Neutral</Chip>
          <Chip variant="primary">Primary</Chip>
          <Badge variant="dot" />
          <Badge variant="count" count={5} />
          <Badge variant="count" count={99} />
        </div>
      </ComponentShowcase>

      {/* Banner */}
      <ComponentShowcase title="Banner">
        <Banner variant="info" message="Your portfolio has been updated" />
        <Banner variant="warning" message="Pending transaction requires attention" />
        <Banner variant="error" message="Failed to sync account data" />
      </ComponentShowcase>

      {/* StateBlock */}
      <ComponentShowcase title="State Block">
        <StateBlock 
          variant="empty"
          icon={<CreditCard size={48} />}
          title="No accounts"
          message="Add account to get started"
          action={<Button variant="primary">Add Account</Button>}
        />
        <StateBlock 
          variant="error"
          icon={<AlertCircle size={48} />}
          title="Connection failed"
          message="Unable to sync data"
          action={<Button variant="primary">Retry</Button>}
        />
      </ComponentShowcase>

      {/* Loader & Skeleton */}
      <ComponentShowcase title="Loader & Skeleton">
        <div style={{ height: '120px', position: 'relative' }}>
          <Loader fullScreen={false} />
        </div>
        <Skeleton type="total" />
        <Skeleton type="list" />
      </ComponentShowcase>

      {/* Dialog */}
      <ComponentShowcase title="Dialog / BottomSheet">
        <Dialog 
          variant="neutral"
          title="Confirm action"
          message="Are you sure you want to proceed?"
          onConfirm={() => {}}
          onCancel={() => {}}
        />
        <Dialog 
          variant="destructive"
          title="Delete account"
          message="This action cannot be undone"
          onConfirm={() => {}}
          onCancel={() => {}}
        />
      </ComponentShowcase>

      {/* Snackbar */}
      <ComponentShowcase title="Snackbar / Toast">
        <Snackbar variant="success" message="Transaction completed" />
        <Snackbar variant="error" message="Failed to process" />
        <Snackbar variant="info" message="Account synced" />
      </ComponentShowcase>

      {/* SegmentedControl */}
      <ComponentShowcase title="Segmented Control">
        <SegmentedControl value={segmentValue} onChange={setSegmentValue} />
      </ComponentShowcase>

      {/* DateField */}
      <ComponentShowcase title="Date Field">
        <DateField label="Transaction Date" value="Feb 10, 2026" />
      </ComponentShowcase>

      {/* AmountField */}
      <ComponentShowcase title="Amount Field">
        <AmountField label="Amount (USD)" value="1,234.56" />
        <AmountField label="Amount (BTC)" value="0.0234567" />
      </ComponentShowcase>
    </section>
  );
}

function ComponentShowcase({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div style={{ marginBottom: 'var(--spacing-24)' }}>
      <h3 className="text-h3" style={{ marginBottom: 'var(--spacing-12)' }}>
        {title}
      </h3>
      <div style={{ 
        display: 'flex',
        flexDirection: 'column',
        gap: 'var(--spacing-12)',
        background: 'var(--surface)',
        padding: 'var(--spacing-16)',
        borderRadius: 'var(--radius-12)',
        border: '1px solid var(--border)'
      }}>
        {children}
      </div>
    </div>
  );
}
