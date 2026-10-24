import { assertEquals } from 'jsr:@std/assert';
import { ApiHttpError, fromError } from './responses.ts';

Deno.test('fromError: client errors are returned as raised', async () => {
  const res = fromError(new ApiHttpError(400, 'VALIDATION_ERROR', 'name is required'));
  assertEquals(res.status, 400);
  const body = await res.json();
  assertEquals(body.error.code, 'VALIDATION_ERROR');
  assertEquals(body.error.message, 'name is required');
});

Deno.test('fromError: database errors never reach the client', async () => {
  const pgError = {
    message: 'duplicate key value violates unique constraint "accounts_pkey"',
    code: '23505',
    details: 'Key (id)=(42) already exists.',
    hint: 'check the table',
  };
  const res = fromError(pgError);
  assertEquals(res.status, 500);
  const body = await res.json();
  assertEquals(body.error, { code: 'INTERNAL_ERROR', message: 'Internal error' });
});

Deno.test('fromError: internal ApiHttpError keeps its code, hides its message', async () => {
  const res = fromError(new ApiHttpError(500, 'INTERNAL_ERROR', 'relation "x" does not exist'));
  const body = await res.json();
  assertEquals(body.error, { code: 'INTERNAL_ERROR', message: 'Internal error' });
});
