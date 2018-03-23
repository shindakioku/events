import 'event_exception.dart';
import 'utils.dart';

import 'dart:async';
import 'dart:mirrors';

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
  Event register(Type event, {String name, Duration duration: null});

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

  Event removeEvent({Type type, String name});

  Event removeEvents();
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

  Event removeEvents() {
    _events = [];
    _listeners = [];

    return this;
  }

  Event removeEvent({Type type, String name}) {
    if (null != type) {
      try {
        var event = _events.firstWhere((EventDTO e) => e.event == type);

        _listeners.removeWhere((l) => l.event == event.name ?? event.event);

        _events.remove(event);
      } catch (e) {}
    }

    if (null != name) {
      try {
        _events.removeWhere((e) => e.name == name);
        _listeners.removeWhere((l) => l.event == name);
      } catch (e) {}
    }

    return this;
  }

  Event asyncCall(bool v) {
    _async = v;

    return this;
  }

  Future<bool> load(List objects) async {
    objects.forEach((m) {
      // If name is null
      var eventName = m['name'] ?? m['event'].toString();

      register(m['event'], name: eventName, duration: m['duration']);

      if (null != m['listeners']) {
        (m['listeners'] as List).forEach((l) => listen(eventName,
            callback: l['callback'], listener: l['listener']));
      }
    });

    return true;
  }

  register(Type event, {String name, Duration duration: null}) {
    _events.add(new EventDTO(name ?? event.toString(), event, duration));

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

    var eventObject = null;

    // If is Type of class
    if (e.event is Type) {
      eventObject = reflectClass(e.event)
          .newInstance(new Symbol(''), posArgs ?? [], symbolize(namedArgs))
          .reflectee;
    } else {
      eventObject = e.event;
    }

    try {
      for (var lis in _listeners.where((l) => l.event == e.name)) {
        if (null != lis.callback) {
          lis.callback(eventObject); // Add try
        }

        if (null != lis.listener) {
          reflectClass(lis.listener).newInstance(new Symbol(''), [eventObject]);
        }
      }
    } catch (error) {
      throw new EventException('Cannot create the object from ${e.name}');
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

    var eventObject = null;

    // If is Type of class
    if (e.event is Type) {
      eventObject = reflectClass(e.event)
          .newInstance(new Symbol(''), posArgs ?? [], symbolize(namedArgs))
          .reflectee;
    } else {
      eventObject = e.event;
    }

    try {
      for (var lis in _listeners.where((l) => l.event == e.name)) {
        if (null != lis.callback) {
          lis.callback(eventObject); // Add try
        }

        if (null != lis.listener) {
          reflectClass(lis.listener).newInstance(new Symbol(''), [eventObject]);
        }
      }
    } catch (error) {
      throw new EventException('Cannot create the object from ${e.name}');
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

  /// [Type] or [Object]
  dynamic event;
  final Duration duration;

  EventDTO(this.name, this.event, this.duration);
}

class ListenerDTO {
  final String event;
  final Function callback;

  /// [Type] or [Object]
  dynamic listener;

  ListenerDTO(this.event, {this.callback, this.listener});
}
