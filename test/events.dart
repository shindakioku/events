class Event1 {
  void execute() {}
}

class Event2 {
  int t;

  void execute() {
    t = 2;
  }
}

class Event3 {
  void execute() {}
}

class Event3Exception {}

class Event4 {
  String data;

  void execute(String v) {
    data = v;
  }
}

class Event5 {
  String data;
  int data1;

  void execute(String v, int c) {
    data = v;
    data1 = c;
  }
}

class Event6 {
  int number;

  void execute(int someInt) {
    number = someInt;
  }
}
