import { assertEquals } from 'jsr:@std/assert';
import { secretsEqual } from './secrets.ts';

Deno.test('secretsEqual: equal, different, different length', async () => {
  assertEquals(await secretsEqual('s3cret', 's3cret'), true);
  assertEquals(await secretsEqual('s3cres', 's3cret'), false);
  assertEquals(await secretsEqual('s3cret-longer', 's3cret'), false);
  assertEquals(await secretsEqual('', 's3cret'), false);
});
