# f_events

A library for Dart developers.

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

    import 'package:f_events/f_events.dart';
    
    class Event {
        void execute() {}
    }

    main() {
        event.register('event_name', new Event());
        event.listen('event_name', (Event event) => print('...'));
        
        event.call('event_name');
    }
    
### Todo

- [ ] Write examples
- [ ] tests 100%
- [ ] Make lazy loading
- [ ] Make mechanism for automatically calling events from property in listener

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/shindakioku/events/issues
