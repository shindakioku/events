import 'event_exception.dart';
import 'utils.dart';

import 'dart:async';

/// You can use it instead of new Event()
final event = new _Event();

abstract class Event {
  factory Event() => event;

  /**
     * If [v] is true, then it will the future call.
     * And you can use it something like this:
     *
     *    event
     *    .asyncCall(true)
     *    .call('event_name')
     *    .then((bool result) => print (result)) // Event was successfully executed
     *    .catchError((e) => print(e));
     *
     * And with sync:
     *
     *    event.asyncCall(false).call('event_name');
     */
  Event asyncCall(bool v);

  /**
     * Conveniently adding your events.
     * [objects] - it's is list with map.
     * Just set any params what is supporting [register] and [listen].
     * If [name] is empty, then it will name of the objects. new SomeEvent() - SomeEvent
     *
     * For example:
     *
     *    var list = [];
     *    var event = {
     *      'event': new SomeEvent(),
     *      'name': 'name',
     *      'duration': const Duration(seconds: 3),
     *      'listeners': [
     *          {'callback': (SomeEvent event) => print('Some text')},
     *          {'listener': new Listener2()}
     *      ]
     *   };
     */
  Future<bool> load(List objects);

  /**
     * Register your event.
     * [duration] can be only with seconds.
     * If not is null, then your event will be called automatically once every N seconds that you set
     */
  Event register(String name, Object event, {Duration duration: null});

  /**
     * Register your listener.
     * [callback] take the object of event.
     *
     * For example:
     *
     *    event.listen('some_event',
     *      (SomeEvent event) => print(event.someProperty));
     */
  Event listen(String name, {Function callback, Object listener});

  /// Trying to call `execute` method of event and all listeners for the event.
  call(String event,
      {List<dynamic> positionalArguments, Map<String, dynamic> namedArguments});

  Future<bool> callAsync(String event,
      {List<dynamic> positionalArguments, Map<String, dynamic> namedArguments});

  bool callCommon(String event,
      {List<dynamic> positionalArguments, Map<String, dynamic> namedArguments});
}

class _Event implements Event {
  List<EventDTO> _events;
  List<ListenerDTO> _listeners;
  bool _async;

  static final _event = new _Event._internal();

  factory _Event() => _event;

  _Event._internal() {
    _events = [];
    _listeners = [];
    _async = false;
  }

  Event asyncCall(bool v) {
    _async = v;

    return this;
  }

  Future<bool> load(List objects) async {
    objects.forEach((m) {
      // If name is null
      var eventName = m['name'] ?? m['event'].runtimeType.toString();

      register(eventName, m['event'], duration: m['duration']);

      if (null != m['listeners']) {
        (m['listeners'] as List).forEach((l) => listen(eventName,
            callback: l['callback'], listener: l['listener']));
      }
    });

    return true;
  }

  Event register(String name, Object event, {Duration duration: null}) {
    _events.add(new EventDTO(name, event, duration));

    return this;
  }

  Event listen(String name, {Function callback, Object listener}) {
    _listeners
        .add(new ListenerDTO(name, callback: callback, listener: listener));

    return this;
  }

  call(String event,
          {List<dynamic> positionalArguments,
          Map<String, dynamic> namedArguments}) =>
      _async
          ? _callWithAsync(event,
              posArgs: positionalArguments, namedArgs: namedArguments)
          : _callCommon(event,
              posArgs: positionalArguments, namedArgs: namedArguments);

  Future<bool> callAsync(String event,
          {List<dynamic> positionalArguments,
          Map<String, dynamic> namedArguments}) =>
      _callWithAsync(event,
          posArgs: positionalArguments, namedArgs: namedArguments);

  bool callCommon(String event,
          {List<dynamic> positionalArguments,
          Map<String, dynamic> namedArguments}) =>
      _callCommon(event,
          posArgs: positionalArguments, namedArgs: namedArguments);

  Future<bool> _callWithAsync(String eventName,
      {List<dynamic> posArgs, Map<String, dynamic> namedArgs}) async {
    EventDTO e = null;

    try {
      e = _events.firstWhere((ev) => ev.name == eventName);
    } catch (error) {
      throw new EventException(error.message);
    }

    try {
      Function.apply(e.event.execute, posArgs, symbolize(namedArgs));
    } catch (error) {
      throw new EventException('Event must have the `execute` method.');
    }

    for (var lis in _listeners.where((l) => l.event == e.name)) {
      try {
        if (null != lis.callback) {
          lis.callback(e.event);
        }

        if (null != lis.listener) {
          lis.listener.handle(e.event);
        }
      } catch (error) {
        throw new EventException('Listener must have the `handler` method.');
      }
    }

    if (null != e.duration) {
      new Timer(
          e.duration,
          () => _callWithAsync(eventName,
              posArgs: posArgs, namedArgs: namedArgs));
    }

    return true;
  }

  bool _callCommon(String eventName,
      {List<dynamic> posArgs, Map<String, dynamic> namedArgs}) {
    EventDTO e = null;

    try {
      e = _events.firstWhere((ev) => ev.name == eventName);
    } catch (error) {
      throw new EventException(error.message);
    }

    try {
      Function.apply(e.event.execute, posArgs, symbolize(namedArgs));
    } catch (error) {
      throw new EventException('Event must have the `execute` method.');
    }

    for (var lis in _listeners.where((l) => l.event == e.name)) {
      try {
        if (null != lis.callback) {
          lis.callback(e.event);
        }

        if (null != lis.listener) {
          lis.listener.handle(e.event);
        }
      } catch (error) {
        throw new EventException('Listener must have the `handle` method.');
      }
    }

    if (null != e.duration) {
      new Timer(e.duration,
          () => _callCommon(eventName, posArgs: posArgs, namedArgs: namedArgs));
    }

    return true;
  }
}

class EventDTO {
  final String name;
  final Object event;
  final Duration duration;

  const EventDTO(this.name, this.event, this.duration);
}

class ListenerDTO {
  final String event;
  final Function callback;
  final Object listener;

  const ListenerDTO(this.event, {this.callback, this.listener});
}
