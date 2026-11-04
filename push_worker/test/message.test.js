import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  bookingMessage,
  cancelledMessage,
  dateLabel,
  dayInBelgrade,
  hourInBelgrade,
  reminderBody,
  reminderMessage,
  tomorrowInBelgrade,
} from '../src/message.js';

test('midnight on a Belgrade phone is that day, in winter and in summer', () => {
  assert.equal(dayInBelgrade(new Date('2026-11-13T23:00:00Z')), '2026-11-14');
  assert.equal(dayInBelgrade(new Date('2026-07-13T22:00:00Z')), '2026-07-14');
});

test('days stay right around both clock changes', () => {
  // Clocks go forward on 2026-03-29, back on 2026-10-25.
  assert.equal(dayInBelgrade(new Date('2026-03-28T23:00:00Z')), '2026-03-29');
  assert.equal(dayInBelgrade(new Date('2026-03-29T22:00:00Z')), '2026-03-30');
  assert.equal(dayInBelgrade(new Date('2026-10-24T22:00:00Z')), '2026-10-25');
  assert.equal(dayInBelgrade(new Date('2026-10-25T23:00:00Z')), '2026-10-26');
});

test('it is 21:00 at 19:00 UTC in summer and 20:00 UTC in winter', () => {
  assert.equal(hourInBelgrade(new Date('2026-07-01T19:00:00Z')), 21);
  assert.equal(hourInBelgrade(new Date('2026-07-01T20:00:00Z')), 22);
  assert.equal(hourInBelgrade(new Date('2026-12-01T19:00:00Z')), 20);
  assert.equal(hourInBelgrade(new Date('2026-12-01T20:00:00Z')), 21);
});

test('midnight in Belgrade is hour 0, not 24', () => {
  assert.equal(hourInBelgrade(new Date('2026-12-01T23:00:00Z')), 0);
});

test('tomorrow is the next day, even on the evening the clocks change', () => {
  assert.equal(tomorrowInBelgrade(new Date('2026-11-13T20:00:00Z')), '2026-11-14');
  // The evenings before each change, and the evenings of the change.
  assert.equal(tomorrowInBelgrade(new Date('2026-03-28T20:00:00Z')), '2026-03-29');
  assert.equal(tomorrowInBelgrade(new Date('2026-03-29T19:00:00Z')), '2026-03-30');
  assert.equal(tomorrowInBelgrade(new Date('2026-10-24T19:00:00Z')), '2026-10-25');
  assert.equal(tomorrowInBelgrade(new Date('2026-10-25T20:00:00Z')), '2026-10-26');
  // Across the end of a year.
  assert.equal(tomorrowInBelgrade(new Date('2026-12-31T20:00:00Z')), '2027-01-01');
});

test('a title shows the date without leading zeros', () => {
  assert.equal(dateLabel('2026-11-14'), '14.11.2026.');
  assert.equal(dateLabel('2027-01-05'), '5.1.2027.');
});

test('a new booking names its day and carries its text', () => {
  assert.deepEqual(bookingMessage('2026-11-14', 'Opel Astra, Mika, 10h'), {
    data: { type: 'appointment', day: '2026-11-14' },
    android: {
      priority: 'high',
      notification: {
        title_loc_key: 'appointment_notification_title',
        title_loc_args: ['14.11.2026.'],
        body: 'Opel Astra, Mika, 10h',
        channel_id: 'appointments',
      },
    },
  });
});

test('a cancelled booking names its day and carries its text', () => {
  const { data, android } = cancelledMessage('2026-11-14', 'Opel Astra, Mika, 10h');
  assert.deepEqual(data, { type: 'cancelled', day: '2026-11-14' });
  assert.deepEqual(android.notification, {
    title_loc_key: 'appointment_cancelled_title',
    title_loc_args: ['14.11.2026.'],
    body: 'Opel Astra, Mika, 10h',
    channel_id: 'appointments',
  });
});

test('a reminder lists the bookings of the day, one per line', () => {
  const message = reminderMessage('2026-11-14', ['Opel, 10h', 'Golf, 12h']);
  assert.deepEqual(message.data, { type: 'reminder', day: '2026-11-14' });
  const { notification } = message.android;
  assert.equal(notification.title_loc_key, 'appointment_reminder_title');
  assert.deepEqual(notification.title_loc_args, ['14.11.2026.']);
  assert.equal(notification.body, 'Opel, 10h\nGolf, 12h');
  assert.equal(notification.channel_id, 'appointments');
});

test('a long reminder is cut between bookings and fits in 4 KB', () => {
  // The longest bookings the rules allow, in letters of two bytes each.
  const long = 'š'.repeat(500);
  const message = reminderMessage('2026-11-14', Array(20).fill(long));
  const { body } = message.android.notification;
  assert.ok(body.endsWith('\n…'));
  assert.ok(body.split('\n').slice(0, -1).every((line) => line === long));
  const size = new TextEncoder().encode(
    JSON.stringify({ message: { token: 'x'.repeat(200), ...message } }),
  ).length;
  assert.ok(size < 4096, `${size} bytes`);
});

test('a short list is not cut', () => {
  assert.equal(reminderBody(['a', 'b']), 'a\nb');
});
