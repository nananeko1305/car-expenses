import { createRemoteJWKSet, jwtVerify } from 'jose';

import { connect } from './google.js';
import {
  bookingMessage,
  dayInBelgrade,
  hourInBelgrade,
  reminderMessage,
  tomorrowInBelgrade,
} from './message.js';

const FIREBASE_KEYS = createRemoteJWKSet(
  new URL(
    'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
  ),
);

// The free plan allows 50 outside calls per run. Everything else in a run
// takes at most 8, and each phone at most 2: its message, and deleting a
// token that has gone stale.
const MAX_PHONES = 20;

const CLAIM_ATTEMPTS = 2;
const REMINDER_HOUR = 21;
const FORTY_EIGHT_HOURS_MS = 48 * 60 * 60 * 1000;

const answer = (status) => new Response(null, { status });

/** The uid of a valid Firebase ID token in [request], or null. */
async function callerOf(request, env) {
  const header = request.headers.get('Authorization') ?? '';
  if (!header.startsWith('Bearer ')) return null;
  const project = env.FIREBASE_PROJECT_ID;
  try {
    const { payload } = await jwtVerify(header.slice(7), FIREBASE_KEYS, {
      issuer: `https://securetoken.google.com/${project}`,
      audience: project,
      algorithms: ['RS256'],
      requiredClaims: ['exp', 'sub'],
    });
    return payload.sub;
  } catch {
    return null;
  }
}

/** The booking id in [request], or null when it could not be one. */
async function appointmentIdOf(request) {
  const body = await request.json().catch(() => null);
  const id = body?.appointmentId;
  return typeof id === 'string' && /^[A-Za-z0-9]{1,128}$/.test(id) ? id : null;
}

function activeUids(users) {
  return new Set(users.filter((u) => u.disabled === false).map((u) => u.id));
}

/** Pushes [message] to the phones of active accounts, keeping the list tidy. */
async function sendToActive(google, users, tokens, message) {
  const active = activeUids(users);
  const phones = tokens.filter((token) => active.has(token.uid));
  if (phones.length > MAX_PHONES) {
    console.error(`Only ${MAX_PHONES} of ${phones.length} phones get this push`);
  }
  const results = await Promise.all(
    phones.slice(0, MAX_PHONES).map(async (phone) => ({
      token: phone.id,
      result: await google.send(phone.id, message),
    })),
  );
  const stale = results.filter((r) => r.result === 'unregistered');
  await Promise.all(stale.map((r) => google.deleteToken(r.token)));
  const failed = results.filter((r) => r.result === 'failed').length;
  if (failed > 0) console.error(`${failed} of ${results.length} pushes failed`);
}

/**
 * Marks a booking as announced unless it changed meanwhile, so that only
 * one caller ever sends. An edit since the read is not a lost race: then it
 * reads the booking again and tries once more. Returns the booking to send,
 * or the status to answer with instead.
 */
async function claim(google, read) {
  const path = `appointments/${read.id}`;
  let booking = read;
  for (let attempt = 1; ; attempt++) {
    const won = await google.writeIf(
      path,
      { announced: true },
      { updateTime: booking.updateTime },
    );
    if (won) return { booking };
    // The app tries again on its next start.
    if (attempt === CLAIM_ATTEMPTS) return { status: 409 };
    booking = await google.get(path);
    if (booking?.announced !== false) return { status: 204 };
  }
}

async function announce(request, env) {
  const uid = await callerOf(request, env);
  if (!uid) return answer(401);
  const id = await appointmentIdOf(request);
  if (!id) return answer(400);

  const google = await connect(env);
  const [users, tokens, booking] = await Promise.all([
    google.list('users'),
    google.list('pushTokens'),
    google.get(`appointments/${id}`),
  ]);
  if (!booking) return answer(404);
  if (!activeUids(users).has(uid) || booking.ownerId !== uid) return answer(403);
  // Only an explicit false: bookings from before this have no such field.
  if (booking.announced !== false) return answer(204);

  const claimed = await claim(google, booking);
  if (claimed.status) return answer(claimed.status);

  const day = dayInBelgrade(new Date(claimed.booking.date));
  await sendToActive(
    google,
    users,
    tokens,
    bookingMessage(day, claimed.booking.text),
  );
  return answer(204);
}

/** Tomorrow's bookings as one push, once, at 21:00 in Belgrade. */
async function remind(env, now) {
  if (hourInBelgrade(now) !== REMINDER_HOUR) return;
  const google = await connect(env);
  const day = tomorrowInBelgrade(now);
  const [sent, users, tokens, soon] = await Promise.all([
    google.get('meta/reminder'),
    google.list('users'),
    google.list('pushTokens'),
    google.bookingsBetween(now, new Date(now.getTime() + FORTY_EIGHT_HOURS_MS)),
  ]);
  if (sent?.day === day) return;
  const written = (booking) => Date.parse(booking.createdAt) || 0;
  const texts = soon
    .filter((booking) => dayInBelgrade(new Date(booking.date)) === day)
    .sort((a, b) => written(a) - written(b))
    .map((booking) => booking.text);
  if (texts.length === 0) return;

  const won = await google.writeIf(
    'meta/reminder',
    { day },
    sent ? { updateTime: sent.updateTime } : { exists: false },
  );
  if (!won) return;
  await sendToActive(google, users, tokens, reminderMessage(day, texts));
}

export default {
  async fetch(request, env) {
    if (new URL(request.url).pathname !== '/announce') return answer(404);
    if (request.method !== 'POST') return answer(405);
    try {
      return await announce(request, env);
    } catch (error) {
      console.error(`Announcing failed: ${error.message}`);
      return answer(500);
    }
  },

  scheduled(event, env, ctx) {
    ctx.waitUntil(remind(env, new Date(event.scheduledTime)));
  },
};
