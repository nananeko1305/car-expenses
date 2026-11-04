// The text and dates of the pushes: no I/O, so they can be tested alone.

const TIME_ZONE = 'Europe/Belgrade';

// FCM refuses a message over 4 KB; this leaves room for the rest of it.
const MAX_BODY_BYTES = 3000;

const DAY_MS = 24 * 60 * 60 * 1000;

function partsInBelgrade(date, options) {
  const format = new Intl.DateTimeFormat('en-GB', {
    timeZone: TIME_ZONE,
    ...options,
  });
  return Object.fromEntries(
    format.formatToParts(date).map((part) => [part.type, part.value]),
  );
}

/** The day [date] falls on in Belgrade, as yyyy-MM-dd. */
export function dayInBelgrade(date) {
  const { year, month, day } = partsInBelgrade(date, {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  return `${year}-${month}-${day}`;
}

/** The hour (0-23) on the clock in Belgrade at [date]. */
export function hourInBelgrade(date) {
  return Number(
    partsInBelgrade(date, { hour: '2-digit', hourCycle: 'h23' }).hour,
  );
}

/**
 * The day after [now]. In the evening, 24 hours later is always the next
 * day, even when the clocks change that night.
 */
export function tomorrowInBelgrade(now) {
  return dayInBelgrade(new Date(now.getTime() + DAY_MS));
}

/** "2026-11-14" as a title shows it: "14.11.2026." */
export function dateLabel(day) {
  const [year, month, date] = day.split('-').map(Number);
  return `${date}.${month}.${year}.`;
}

/** One booking per line, cut short when FCM would refuse the message. */
export function reminderBody(texts) {
  const encoder = new TextEncoder();
  const lines = [];
  let bytes = 0;
  for (const text of texts) {
    bytes += encoder.encode(text).length + 1;
    if (bytes > MAX_BODY_BYTES) {
      lines.push('…');
      break;
    }
    lines.push(text);
  }
  return lines.join('\n');
}

// The title is a string resource in the app, so each phone shows it in its
// own language; see android/app/src/main/res/values*/strings.xml.
function message(type, titleKey, day, body) {
  return {
    data: { type, day },
    android: {
      priority: 'high',
      notification: {
        title_loc_key: titleKey,
        title_loc_args: [dateLabel(day)],
        body,
        channel_id: 'appointments',
      },
    },
  };
}

export function bookingMessage(day, text) {
  return message('appointment', 'appointment_notification_title', day, text);
}

export function cancelledMessage(day, text) {
  return message('cancelled', 'appointment_cancelled_title', day, text);
}

export function reminderMessage(day, texts) {
  return message(
    'reminder',
    'appointment_reminder_title',
    day,
    reminderBody(texts),
  );
}
