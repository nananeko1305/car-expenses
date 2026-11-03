import assert from 'node:assert/strict';
import { afterEach, beforeEach, test } from 'node:test';

import { exportJWK, exportPKCS8, generateKeyPair, SignJWT } from 'jose';

import worker from '../src/index.js';

const PROJECT = 'test-project';
const DOCUMENTS = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;
const FCM = `https://fcm.googleapis.com/v1/projects/${PROJECT}/messages:send`;
const JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

const firebaseKeys = await generateKeyPair('RS256', { extractable: true });
const otherKeys = await generateKeyPair('RS256', { extractable: true });
const accountKeys = await generateKeyPair('RS256', { extractable: true });
const publicJwk = {
  ...(await exportJWK(firebaseKeys.publicKey)),
  kid: 'firebase',
  alg: 'RS256',
  use: 'sig',
};

const env = {
  FIREBASE_PROJECT_ID: PROJECT,
  GOOGLE_SERVICE_ACCOUNT: JSON.stringify({
    client_email: 'push-worker@test.iam.gserviceaccount.com',
    private_key: await exportPKCS8(accountKeys.privateKey),
  }),
};

function idToken(uid, options = {}) {
  const {
    key = firebaseKeys.privateKey,
    audience = PROJECT,
    issuer = `https://securetoken.google.com/${PROJECT}`,
    expires = '1h',
  } = options;
  return new SignJWT({})
    .setProtectedHeader({ alg: 'RS256', kid: 'firebase' })
    .setSubject(uid)
    .setAudience(audience)
    .setIssuer(issuer)
    .setIssuedAt()
    .setExpirationTime(expires)
    .sign(key);
}

// An in-memory Firestore and FCM behind a fake fetch. Documents map a path
// to plain fields; `log` records every outside call in order.
let store;
let log;
let beforeWrite;
let unregistered;
const realFetch = globalThis.fetch;

function toDocument(path, doc) {
  const fields = {};
  for (const [name, value] of Object.entries(doc)) {
    if (name === 'updateTime') continue;
    if (typeof value === 'boolean') fields[name] = { booleanValue: value };
    else if (name === 'date' || name === 'createdAt') {
      fields[name] = { timestampValue: value };
    } else fields[name] = { stringValue: value };
  }
  return {
    name: `projects/${PROJECT}/databases/(default)/documents/${path}`,
    fields,
    updateTime: doc.updateTime,
  };
}

const json = (body, status = 200) =>
  new Response(JSON.stringify(body), { status });

function fakeFetch(input, init = {}) {
  const url = new URL(input);
  const method = init.method ?? 'GET';
  const base = url.origin + url.pathname;
  log.push(`${method} ${decodeURIComponent(base).replace(DOCUMENTS, '')}`);

  if (base === JWKS_URL) return json({ keys: [publicJwk] });
  if (base === 'https://oauth2.googleapis.com/token') {
    return json({ access_token: 'google-token' });
  }
  if (base === FCM) {
    const { message } = JSON.parse(init.body);
    sent.push(message);
    if (unregistered.has(message.token)) {
      return json(
        {
          error: {
            status: 'NOT_FOUND',
            details: [{ errorCode: 'UNREGISTERED' }],
          },
        },
        404,
      );
    }
    return json({ name: 'ok' });
  }
  if (!base.startsWith(DOCUMENTS)) throw new Error(`Unexpected ${base}`);
  assert.equal(init.headers.Authorization, 'Bearer google-token');

  const path = decodeURIComponent(base.slice(DOCUMENTS.length + 1));
  if (base.endsWith(':runQuery')) {
    const { where } = JSON.parse(init.body).structuredQuery;
    const [from, to] = where.compositeFilter.filters.map((f) =>
      Date.parse(f.fieldFilter.value.timestampValue),
    );
    const rows = Object.entries(store)
      .filter(([p]) => p.startsWith('appointments/'))
      .filter(([, d]) => Date.parse(d.date) >= from && Date.parse(d.date) < to)
      .map(([p, d]) => ({ document: toDocument(p, d) }));
    return json(rows.length ? rows : [{ readTime: 'now' }]);
  }
  if (method === 'DELETE') {
    delete store[path];
    return json({});
  }
  // Answers as the Firestore emulator does for these preconditions.
  if (base.endsWith(':commit')) {
    beforeWrite?.();
    const [write] = JSON.parse(init.body).writes;
    const target = write.update.name.split('/documents/')[1];
    const { updateTime, exists } = write.currentDocument;
    if (exists === false && store[target]) {
      return json({ error: { status: 'ALREADY_EXISTS' } }, 409);
    }
    if (updateTime && store[target]?.updateTime !== updateTime) {
      return json({ error: { status: 'FAILED_PRECONDITION' } }, 400);
    }
    assert.deepEqual(
      write.updateMask.fieldPaths,
      Object.keys(write.update.fields),
    );
    const decoded = {};
    for (const [name, value] of Object.entries(write.update.fields)) {
      decoded[name] = value.booleanValue ?? value.stringValue;
    }
    store[target] = { ...store[target], ...decoded, updateTime: 'after-write' };
    return json({ writeResults: [{}], commitTime: 'now' });
  }
  if (store[path]) return json(toDocument(path, store[path]));
  const documents = Object.entries(store)
    .filter(([p]) => p.startsWith(`${path}/`))
    .map(([p, d]) => toDocument(p, d));
  if (documents.length > 0) return json({ documents });
  if (path === 'users' || path === 'pushTokens') return json({});
  return json({ error: { status: 'NOT_FOUND' } }, 404);
}

let sent;

beforeEach(() => {
  log = [];
  sent = [];
  beforeWrite = null;
  unregistered = new Set();
  store = {
    'users/mika': { disabled: false, updateTime: 't0' },
    'users/pera': { disabled: false, updateTime: 't0' },
    'users/zika': { disabled: true, updateTime: 't0' },
    'pushTokens/phone-mika': { uid: 'mika', updateTime: 't0' },
    'pushTokens/phone-pera': { uid: 'pera', updateTime: 't0' },
    'pushTokens/phone-zika': { uid: 'zika', updateTime: 't0' },
    'pushTokens/phone-gone': { uid: 'someone-deleted', updateTime: 't0' },
    'appointments/a1': {
      ownerId: 'mika',
      date: '2026-11-13T23:00:00Z',
      text: 'Opel Astra, Mika, 10h',
      announced: false,
      updateTime: 't1',
    },
  };
  globalThis.fetch = async (input, init) => fakeFetch(input, init);
});

afterEach(() => {
  globalThis.fetch = realFetch;
});

async function post(token, body = { appointmentId: 'a1' }) {
  const headers = token ? { Authorization: `Bearer ${token}` } : {};
  return worker.fetch(
    new Request('https://push.test/announce', {
      method: 'POST',
      headers,
      body: JSON.stringify(body),
    }),
    env,
  );
}

const writes = () => log.filter((line) => line.endsWith(':commit'));

test('a new booking reaches every active account, the author too', async () => {
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 204);
  assert.deepEqual(sent.map((m) => m.token).sort(), [
    'phone-mika',
    'phone-pera',
  ]);
  const [message] = sent;
  assert.deepEqual(message.data, { type: 'appointment', day: '2026-11-14' });
  assert.deepEqual(message.android.notification.title_loc_args, ['14.11.2026.']);
  assert.equal(message.android.notification.body, 'Opel Astra, Mika, 10h');
  assert.equal(store['appointments/a1'].announced, true);
});

test('the booking is marked only after every read, and before any send', async () => {
  await post(await idToken('mika'));
  const mark = log.findIndex((line) => line.endsWith(':commit'));
  const lastRead = log.findLastIndex((line) => line.startsWith('GET'));
  const firstSend = log.findIndex((line) => line === `POST ${FCM}`);
  assert.ok(lastRead < mark, log.join('\n'));
  assert.ok(mark < firstSend, log.join('\n'));
});

test('a repeated call sends nothing', async () => {
  const token = await idToken('mika');
  await post(token);
  sent = [];
  const response = await post(token);
  assert.equal(response.status, 204);
  assert.deepEqual(sent, []);
});

test('a booking from before this version never fires', async () => {
  delete store['appointments/a1'].announced;
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 204);
  assert.deepEqual(sent, []);
  assert.deepEqual(writes(), []);
});

test('an edit between the read and the mark sends the edited text', async () => {
  beforeWrite = () => {
    beforeWrite = null;
    store['appointments/a1'].text = 'Opel Astra, Mika, 12h';
    store['appointments/a1'].updateTime = 't2';
  };
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 204);
  assert.equal(writes().length, 2);
  assert.equal(sent.length, 2);
  assert.equal(sent[0].android.notification.body, 'Opel Astra, Mika, 12h');
  assert.equal(store['appointments/a1'].announced, true);
});

test('another call that marked it first means this one sends nothing', async () => {
  beforeWrite = () => {
    beforeWrite = null;
    store['appointments/a1'].announced = true;
    store['appointments/a1'].updateTime = 't2';
  };
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 204);
  assert.deepEqual(sent, []);
});

test('a booking deleted meanwhile sends nothing', async () => {
  beforeWrite = () => {
    beforeWrite = null;
    delete store['appointments/a1'];
  };
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 204);
  assert.deepEqual(sent, []);
});

test('it gives up after a second lost write, for the app to retry later', async () => {
  let edits = 0;
  beforeWrite = () => {
    edits += 1;
    store['appointments/a1'].updateTime = `edit-${edits}`;
  };
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 409);
  assert.equal(writes().length, 2);
  assert.deepEqual(sent, []);
  assert.equal(store['appointments/a1'].announced, false);
});

test('a bad ID token is refused before anything is read', async () => {
  const expired = await idToken('mika', {
    expires: new Date(Date.now() - 1000),
  });
  for (const token of [
    null,
    'not-a-token',
    expired,
    await idToken('mika', { key: otherKeys.privateKey }),
    await idToken('mika', { audience: 'another-project' }),
    await idToken('mika', { issuer: 'https://securetoken.google.com/other' }),
  ]) {
    log = [];
    const response = await post(token);
    assert.equal(response.status, 401, String(token));
    assert.deepEqual(
      log.filter((line) => line !== `GET ${JWKS_URL}`),
      [],
    );
  }
  assert.deepEqual(sent, []);
});

test('only the author of the booking may announce it', async () => {
  const response = await post(await idToken('pera'));
  assert.equal(response.status, 403);
  assert.deepEqual(sent, []);
  assert.deepEqual(writes(), []);
});

test('a disabled account cannot announce, even its own booking', async () => {
  store['appointments/a1'].ownerId = 'zika';
  const response = await post(await idToken('zika'));
  assert.equal(response.status, 403);
  assert.deepEqual(sent, []);
});

test('a token for an account with no profile is refused', async () => {
  store['appointments/a1'].ownerId = 'stranger';
  const response = await post(await idToken('stranger'));
  assert.equal(response.status, 403);
  assert.deepEqual(sent, []);
});

test('a booking that does not exist answers 404', async () => {
  const response = await post(await idToken('mika'), { appointmentId: 'nope' });
  assert.equal(response.status, 404);
});

test('an id that could not be a booking is refused before any read', async () => {
  const token = await idToken('mika');
  for (const appointmentId of ['../users/mika', '', 7, null]) {
    log = [];
    const response = await post(token, { appointmentId });
    assert.equal(response.status, 400, String(appointmentId));
    assert.equal(log.some((line) => line.includes('/appointments')), false);
  }
});

test('other paths and methods are not served', async () => {
  const get = await worker.fetch(new Request('https://push.test/announce'), env);
  assert.equal(get.status, 405);
  const other = await worker.fetch(
    new Request('https://push.test/users', { method: 'POST' }),
    env,
  );
  assert.equal(other.status, 404);
});

test('a token that is no longer registered is deleted, others are kept', async () => {
  unregistered = new Set(['phone-pera']);
  const response = await post(await idToken('mika'));
  assert.equal(response.status, 204);
  assert.equal(store['pushTokens/phone-pera'], undefined);
  assert.ok(store['pushTokens/phone-mika']);
  assert.ok(store['pushTokens/phone-zika']);
});

test('a failure inside Google answers 500 and names no secret', async () => {
  const errors = [];
  const realError = console.error;
  console.error = (message) => errors.push(message);
  globalThis.fetch = async (input, init) => {
    if (new URL(input).origin === 'https://oauth2.googleapis.com') {
      return json({ error: 'invalid_grant' }, 400);
    }
    return fakeFetch(input, init);
  };
  try {
    const response = await post(await idToken('mika'));
    assert.equal(response.status, 500);
    assert.deepEqual(errors, ['Announcing failed: Google sign-in failed with 400']);
  } finally {
    console.error = realError;
  }
});

test('a malformed secret is not quoted in the log', async () => {
  const errors = [];
  const realError = console.error;
  console.error = (message) => errors.push(message);
  try {
    const response = await worker.fetch(
      new Request('https://push.test/announce', {
        method: 'POST',
        headers: { Authorization: `Bearer ${await idToken('mika')}` },
        body: JSON.stringify({ appointmentId: 'a1' }),
      }),
      { ...env, GOOGLE_SERVICE_ACCOUNT: 'secret-text-here' },
    );
    assert.equal(response.status, 500);
    assert.equal(errors.join().includes('secret-text'), false);
  } finally {
    console.error = realError;
  }
});

function addPhones(count) {
  for (let i = 0; i < count; i++) {
    store[`pushTokens/extra-${i}`] = { uid: 'pera', updateTime: 't0' };
  }
}

test('even with stale phones and an edit, a run stays under 50 calls', async () => {
  addPhones(40);
  unregistered = new Set(
    Object.keys(store)
      .filter((path) => path.startsWith('pushTokens/'))
      .map((path) => path.split('/')[1]),
  );
  beforeWrite = () => {
    beforeWrite = null;
    store['appointments/a1'].updateTime = 't2';
  };
  const realError = console.error;
  console.error = () => {};
  try {
    const response = await post(await idToken('mika'));
    assert.equal(response.status, 204);
  } finally {
    console.error = realError;
  }
  assert.ok(log.length <= 50, `${log.length} calls`);
  assert.equal(sent.length, 20);
});

// Reminders.

async function fire(when) {
  const pending = [];
  worker.scheduled(
    { scheduledTime: Date.parse(when) },
    env,
    { waitUntil: (promise) => pending.push(promise) },
  );
  await Promise.all(pending);
}

const WINTER_21H = '2026-11-13T20:00:00Z';
const SUMMER_21H = '2026-07-13T19:00:00Z';

function book(id, date, text, createdAt = '2026-11-01T10:00:00Z') {
  store[`appointments/${id}`] = {
    ownerId: 'mika',
    date,
    text,
    createdAt,
    announced: true,
    updateTime: 't1',
  };
}

test('at 21:00 in winter, tomorrow\'s bookings go out as one push', async () => {
  book('later', '2026-11-13T23:00:00Z', 'Golf, 12h', '2026-11-02T10:00:00Z');
  await fire(WINTER_21H);
  assert.deepEqual(sent.map((m) => m.token).sort(), [
    'phone-mika',
    'phone-pera',
  ]);
  const [message] = sent;
  assert.deepEqual(message.data, { type: 'reminder', day: '2026-11-14' });
  assert.equal(
    message.android.notification.title_loc_key,
    'appointment_reminder_title',
  );
  assert.deepEqual(message.android.notification.title_loc_args, ['14.11.2026.']);
  assert.ok(message.android.notification.body.includes('Golf, 12h'));
  assert.ok(
    message.android.notification.body.includes('Opel Astra, Mika, 10h'),
  );
});

test('a reminder lists the day in the order the bookings were written', async () => {
  delete store['appointments/a1'];
  book('second', '2026-11-13T23:00:00Z', 'drugi', '2026-11-02T10:00:00Z');
  book('first', '2026-11-13T23:00:00Z', 'prvi', '2026-11-01T10:00:00Z');
  await fire(WINTER_21H);
  assert.equal(sent[0].android.notification.body, 'prvi\ndrugi');
});

test('at 21:00 in summer it fires too', async () => {
  delete store['appointments/a1'];
  book('july', '2026-07-13T22:00:00Z', 'Letnji termin');
  await fire(SUMMER_21H);
  assert.deepEqual(sent[0].data, { type: 'reminder', day: '2026-07-14' });
});

test('the other cron does nothing at all, in winter and in summer', async () => {
  for (const when of ['2026-11-13T19:00:00Z', '2026-07-13T20:00:00Z']) {
    log = [];
    await fire(when);
    assert.deepEqual(log, [], when);
  }
  assert.deepEqual(sent, []);
});

test('only tomorrow goes out: not today, not the day after', async () => {
  delete store['appointments/a1'];
  book('dayAfter', '2026-11-14T23:00:00Z', 'prekosutra');
  await fire(WINTER_21H);
  assert.deepEqual(sent, []);
  book('tomorrow', '2026-11-13T23:00:00Z', 'sutra');
  await fire(WINTER_21H);
  assert.equal(sent[0].android.notification.body, 'sutra');
});

test('no bookings tomorrow: no push, and nothing recorded', async () => {
  delete store['appointments/a1'];
  await fire(WINTER_21H);
  assert.deepEqual(sent, []);
  assert.deepEqual(writes(), []);
});

test('firing twice the same evening sends once', async () => {
  await fire(WINTER_21H);
  assert.equal(sent.length, 2);
  await fire(WINTER_21H);
  assert.equal(sent.length, 2);
  assert.equal(store['meta/reminder'].day, '2026-11-14');
});

test('the next evening goes out again', async () => {
  await fire(WINTER_21H);
  sent = [];
  book('next', '2026-11-14T23:00:00Z', 'Sledeci dan');
  await fire('2026-11-14T20:00:00Z');
  assert.equal(sent.length, 2);
  assert.equal(store['meta/reminder'].day, '2026-11-15');
});

test('the mark is written after every read, and before any send', async () => {
  await fire(WINTER_21H);
  const mark = log.findIndex((line) => line.endsWith(':commit'));
  const lastRead = log.findLastIndex(
    (line) => line.startsWith('GET') || line.includes(':runQuery'),
  );
  const firstSend = log.findIndex((line) => line === `POST ${FCM}`);
  assert.ok(lastRead < mark, log.join('\n'));
  assert.ok(mark < firstSend, log.join('\n'));
});

test('another run that marked it first means this one sends nothing', async () => {
  beforeWrite = () => {
    beforeWrite = null;
    store['meta/reminder'] = { day: '2026-11-14', updateTime: 't9' };
  };
  await fire(WINTER_21H);
  assert.deepEqual(sent, []);
});

test('a reminder run with many stale phones stays under 50 calls', async () => {
  addPhones(40);
  unregistered = new Set(
    Object.keys(store)
      .filter((path) => path.startsWith('pushTokens/'))
      .map((path) => path.split('/')[1]),
  );
  const realError = console.error;
  console.error = () => {};
  try {
    await fire(WINTER_21H);
  } finally {
    console.error = realError;
  }
  assert.ok(log.length <= 50, `${log.length} calls`);
  assert.equal(sent.length, 20);
});
