import { importPKCS8, SignJWT } from 'jose';

const TOKEN_URL = 'https://oauth2.googleapis.com/token';
const SCOPES = [
  'https://www.googleapis.com/auth/datastore',
  'https://www.googleapis.com/auth/firebase.messaging',
].join(' ');

// What Firestore answers when a precondition fails. The document has
// changed, or is gone, since it was read.
const LOST_RACE_CODES = new Set([404, 409, 412]);
const LOST_RACE_STATUSES = new Set([
  'FAILED_PRECONDITION',
  'ABORTED',
  'ALREADY_EXISTS',
]);

function serviceAccount(env) {
  try {
    return JSON.parse(env.GOOGLE_SERVICE_ACCOUNT);
  } catch {
    // Not the parser's message: it quotes the text it could not read.
    throw new Error('GOOGLE_SERVICE_ACCOUNT is not valid JSON');
  }
}

/** Signs in as the service account and returns a client for its token. */
export async function connect(env) {
  const account = serviceAccount(env);
  const key = await importPKCS8(account.private_key, 'RS256');
  const now = Math.floor(Date.now() / 1000);
  const assertion = await new SignJWT({ scope: SCOPES })
    .setProtectedHeader({ alg: 'RS256', typ: 'JWT' })
    .setIssuer(account.client_email)
    .setAudience(TOKEN_URL)
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(key);
  const response = await fetch(TOKEN_URL, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion,
    }),
  });
  if (!response.ok) {
    throw new Error(`Google sign-in failed with ${response.status}`);
  }
  const { access_token: token } = await response.json();
  return new Google(env.FIREBASE_PROJECT_ID, token);
}

/** A Firestore document as plain values, with its id and update time. */
function decode(document) {
  const fields = {};
  for (const [name, value] of Object.entries(document.fields ?? {})) {
    fields[name] =
      value.stringValue ?? value.booleanValue ?? value.timestampValue ?? null;
  }
  return {
    ...fields,
    id: document.name.split('/').pop(),
    updateTime: document.updateTime,
  };
}

function encode(fields) {
  const encoded = {};
  for (const [name, value] of Object.entries(fields)) {
    encoded[name] =
      typeof value === 'boolean'
        ? { booleanValue: value }
        : { stringValue: value };
  }
  return encoded;
}

class Google {
  constructor(project, token) {
    this.root = `projects/${project}/databases/(default)/documents`;
    this.documents = `https://firestore.googleapis.com/v1/${this.root}`;
    this.messages = `https://fcm.googleapis.com/v1/projects/${project}/messages:send`;
    this.headers = {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    };
  }

  async #fetchOk(what, url, init) {
    const response = await fetch(url, { headers: this.headers, ...init });
    if (!response.ok) {
      throw new Error(`Firestore ${what} failed with ${response.status}`);
    }
    return response.json();
  }

  /** The document at [path], or null when there is none. */
  async get(path) {
    const response = await fetch(`${this.documents}/${path}`, {
      headers: this.headers,
    });
    if (response.status === 404) return null;
    if (!response.ok) {
      throw new Error(`Firestore read failed with ${response.status}`);
    }
    return decode(await response.json());
  }

  /** A whole collection, which here is never more than one page. */
  async list(collection) {
    const { documents = [] } = await this.#fetchOk(
      'list',
      `${this.documents}/${collection}?pageSize=300`,
    );
    return documents.map(decode);
  }

  /** Bookings with `date` from [from] up to, but not including, [to]. */
  async bookingsBetween(from, to) {
    const dateIs = (op, value) => ({
      fieldFilter: {
        field: { fieldPath: 'date' },
        op,
        value: { timestampValue: value.toISOString() },
      },
    });
    const rows = await this.#fetchOk('query', `${this.documents}:runQuery`, {
      method: 'POST',
      body: JSON.stringify({
        structuredQuery: {
          from: [{ collectionId: 'appointments' }],
          where: {
            compositeFilter: {
              op: 'AND',
              filters: [
                dateIs('GREATER_THAN_OR_EQUAL', from),
                dateIs('LESS_THAN', to),
              ],
            },
          },
        },
      }),
    });
    return rows.filter((row) => row.document).map((row) => decode(row.document));
  }

  /**
   * Writes [fields] only if the document still matches [precondition],
   * either {updateTime} or {exists: false}. False means someone else got
   * there first; any other failure throws.
   *
   * Through :commit, not a PATCH with currentDocument in its URL: on the
   * Firestore emulator that reads the update time as 0, and always loses.
   */
  async writeIf(path, fields, precondition) {
    const response = await fetch(`${this.documents}:commit`, {
      method: 'POST',
      headers: this.headers,
      body: JSON.stringify({
        writes: [
          {
            update: { name: `${this.root}/${path}`, fields: encode(fields) },
            updateMask: { fieldPaths: Object.keys(fields) },
            currentDocument: precondition,
          },
        ],
      }),
    });
    if (response.ok) return true;
    if (LOST_RACE_CODES.has(response.status)) return false;
    const body = await response.json().catch(() => ({}));
    if (LOST_RACE_STATUSES.has(body.error?.status)) return false;
    throw new Error(`Firestore write failed with ${response.status}`);
  }

  /** Never throws: one phone's failure must not stop the others. */
  async deleteToken(token) {
    const url = `${this.documents}/pushTokens/${encodeURIComponent(token)}`;
    try {
      await fetch(url, { method: 'DELETE', headers: this.headers });
    } catch (error) {
      console.error(`Deleting a token failed: ${error.name}`);
    }
  }

  /**
   * Sends [message] to one phone: 'sent', 'unregistered' when the phone no
   * longer has that token, or 'failed'. Never throws, as with [deleteToken].
   */
  async send(token, message) {
    try {
      const response = await fetch(this.messages, {
        method: 'POST',
        headers: this.headers,
        body: JSON.stringify({ message: { token, ...message } }),
      });
      if (response.ok) return 'sent';
      const body = await response.json().catch(() => ({}));
      const unregistered = body.error?.details?.some(
        (detail) => detail.errorCode === 'UNREGISTERED',
      );
      return unregistered ? 'unregistered' : 'failed';
    } catch {
      return 'failed';
    }
  }
}
