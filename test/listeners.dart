import 'events.dart';

class Listener1 {
  int t;

  void handle(Event2 event) {
    t = event.t;
  }
}

class Listener2 {
  String someString;
  int someInt;

  void handle(Event5 event) {
    someString = event.data;
    someInt = event.data1;
  }
}
