import 'package:events/events.dart';
import 'package:events/src/event_exception.dart';
import 'events.dart';
import 'listeners.dart';

import 'package:test/test.dart';

import 'dart:math';

void main() {
  test('Try to load one event with name with exception', () {
    var list = [
      {'event': new Event1(), 'name': 'event_1'}
    ];

    event.load(list);

    try {
      event.call('event_1');
    } on EventException catch (e) {
      expect('Bad state: No element', equals(e.toString()));
    }
  });

  test('Try to load one event with name', () async {
    var list = [
      {'event': new Event1(), 'name': 'event_1'}
    ];

    await event.load(list);

    event.call('event_1');
  });

  test('Try to load one event with listener', () async {
    int listenResult = 0;

    var list = [
      {
        'event': new Event1(),
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
        'event': new Event1(),
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
        'event': new Event2(),
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

  test('Try to load one event with listener and property from event', () async {
    var listener = new Listener1();

    var list = [
      {
        'event': new Event2(),
        'name': 'event_2',
        'listeners': [
          {'listener': listener}
        ]
      }
    ];

    await event.load(list);

    event.call('event_2');
    expect(listener.t, equals(2));
  });

  test('Register event and call without listener', () {
    event.register('event_3', new Event3());

    event.call('event_3');
  });

  test('Register event and call without listener with exception', () {
    event.register('event_3_exception', new Event3Exception());

    try {
      event.call('event_3_exception');
    } on EventException catch (e) {
      expect('Event must have the `execute` method.', e.message);
    }
  });

  test('Register event, listener and set data to execute', () async {
    String eventData;

    event.register('event_4', new Event4());
    event.listen('event_4', callback: (Event4 event) => eventData = event.data);

    event.call('event_4', positionalArguments: ['Some string']);

    expect('Some string', equals(eventData));
  });

  test('Register event, listener and set data to execute with async', () async {
    String eventData;

    event.register('event_4', new Event4());
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
    var listener = new Listener2();

    event.register('event_5', new Event5());
    event.listen('event_5', listener: listener);

    event
        .asyncCall(false)
        .call('event_5', positionalArguments: ['Some string 123qwe', 123]);

    expect(listener.someString, equals('Some string 123qwe'));
    expect(listener.someInt, equals(123));
  });

}
