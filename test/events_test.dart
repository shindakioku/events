import 'package:f_events/f_events.dart';
import 'package:f_events/src/event_exception.dart';
import 'events.dart';
import 'listeners.dart';

import 'package:test/test.dart';

import 'dart:math';

void main() {
  test('Try to load one event with name with exception', () {
    var list = [
      {'event': Event1, 'name': 'event_1'}
    ];

    event.load(list);

    try {
      event.call('event_1');
    } on EventException catch (e) {
      expect('Bad state: No element', equals(e.toString()));
    }
  });

  test('Try to load one event with type name', () async {
    var list = [
      {'event': Event1}
    ];

    await event.load(list);

    event.call('Event1');
  });

  test('Try to load one event with listener', () async {
    int listenResult = 0;

    var list = [
      {
        'event': Event1,
        'name': 'event_1',
        'listeners': [
          {'callback': (Event1 event) => listenResult = 1}
        ]
      }
    ];

    await event.load(list);

    event.call('event_1');
    expect(listenResult, equals(1));
  });

  test('Try to load one event with listeners', () async {
    int listenResult = 0;
    int listenResult1 = 0;

    var list = [
      {
        'event': Event1,
        'name': 'event_1',
        'listeners': [
          {'callback': (Event1 event) => listenResult = 1},
          {'callback': (_) => listenResult1 = 2}
        ]
      }
    ];

    await event.load(list);

    event.call('event_1');
    expect(listenResult, equals(1));
    expect(listenResult1, equals(2));
  });

  test('Try to load one event with listener and property from event', () async {
    int listenResult = 0;

    var list = [
      {
        'event': Event2,
        'name': 'event_2',
        'listeners': [
          {'callback': (Event2 event) => listenResult = event.t}
        ]
      }
    ];

    await event.load(list);

    event.call('event_2');
    expect(listenResult, equals(2));
  });

  test('Try to load one event with listener and named property from event',
      () async {
    int listenResult = 0;

    var list = [
      {
        'event': Event7,
        'name': 'event_7',
        'listeners': [
          {'callback': (Event7 event) => listenResult = event.a}
        ]
      }
    ];

    await event.load(list);

    event.call('event_7', namedArguments: {'number': 341});
    expect(listenResult, equals(341));
  });

  test('Try to load one event with listener and property from event', () async {
    var e = null;

    var list = [
      {
        'event': Event2,
        'name': 'event_2',
        'listeners': [
          {'callback': (Event2 event) => e = event}
        ]
      }
    ];

    await event.load(list);

    event.call('event_2');
    expect(e.t, equals(2));
  });

  test('Register event and call without listener', () {
    event.register(Event3);

    event.call('Event3');
  });

  test('Register event and call without listener with exception', () {
    event.register(Event3Exception, name: 'event_3_exception');

    try {
      event.call('event_3_exception');
    } on EventException catch (e) {
      expect('Event must have the `execute` method.', e.message);
    }
  });

  test('Register event, listener and set data to execute', () async {
    String eventData;

    event.register(Event4, name: 'event_4');
    event.listen('event_4', callback: (Event4 event) => eventData = event.data);

    event.call('event_4', positionalArguments: ['Some string']);

    expect('Some string', equals(eventData));
  });

  test('Register event, listener and set data to execute with async', () async {
    String eventData;

    event.register(Event4, name: 'event_4');
    event.listen('event_4', callback: (Event4 event) => eventData = event.data);

    event.asyncCall(true).call('event_4', positionalArguments: [
      'Some '
          'string'
    ]).then((r) {
      expect(true, equals(r));
      expect('Some string', equals(eventData));
    });
  });

  test('Register event, listener and set data to execute', () async {
    var e = null;

    event.register(Event5, name: 'event_5');
    event.listen('event_5', callback: (Event5 event) => e = event);

    event
        .asyncCall(false)
        .call('event_5', positionalArguments: ['Some string 123qwe', 123]);

    expect(e.data, equals('Some string 123qwe'));
    expect(e.data1, equals(123));
  });
}
