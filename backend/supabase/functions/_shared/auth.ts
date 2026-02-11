import { getUserClient } from './supabase.ts';

export type AuthUser = {
  id: string;
  email?: string;
};

export async function requireAuthUser(req: Request): Promise<AuthUser> {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader || !authHeader.toLowerCase().startsWith('bearer ')) {
    throw new Error('Missing Authorization header');
  }

  const userClient = getUserClient(authHeader);
  const { data, error } = await userClient.auth.getUser();
  if (error || !data?.user) {
    throw new Error('Unauthorized');
  }
  return { id: data.user.id, email: data.user.email ?? undefined };
}

