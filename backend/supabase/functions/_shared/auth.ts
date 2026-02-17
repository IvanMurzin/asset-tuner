import type { User } from 'https://esm.sh/@supabase/supabase-js@2.49.1';
import { getAdminClient } from './db.ts';
import { ApiHttpError } from './responses.ts';

export function extractBearerToken(req: Request): string {
  const authHeader = req.headers.get('authorization') ?? req.headers.get('Authorization');
  if (!authHeader) {
    throw new ApiHttpError(401, 'UNAUTHORIZED', 'Missing Authorization header');
  }

  const match = authHeader.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    throw new ApiHttpError(401, 'UNAUTHORIZED', 'Invalid Authorization header format');
  }

  const token = match[1]?.trim();
  if (!token) {
    throw new ApiHttpError(401, 'UNAUTHORIZED', 'Empty bearer token');
  }

  return token;
}

export async function requireUser(req: Request): Promise<User> {
  const token = extractBearerToken(req);
  const supabase = getAdminClient();
  const { data, error } = await supabase.auth.getUser(token);

  if (error || !data?.user) {
    throw new ApiHttpError(401, 'UNAUTHORIZED', 'Invalid or expired token');
  }

  return data.user;
}
