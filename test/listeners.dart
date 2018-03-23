import 'events.dart';

class Listener1 {
  int t;

  Listener1(Event2 event) {
    t = event.t;
  }
}

class Listener2 {
  String someString;
  int someInt;

  Listener2(Event5 event) {
    someString = event.data;
    someInt = event.data1;
  }
}
