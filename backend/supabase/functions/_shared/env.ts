export function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new Error(`Missing env var: ${name}`);
  }
  return value;
}

export function envFlag(name: string, defaultValue = false): boolean {
  const raw = Deno.env.get(name);
  if (raw == null) {
    return defaultValue;
  }
  return raw === '1' || raw.toLowerCase() === 'true' || raw.toLowerCase() === 'yes';
}

