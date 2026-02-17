export function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value || value.trim().length === 0) {
    throw new Error(`Missing required env: ${name}`);
  }
  return value;
}

export function optionalEnv(name: string): string | null {
  const value = Deno.env.get(name);
  if (!value || value.trim().length === 0) {
    return null;
  }
  return value;
}
