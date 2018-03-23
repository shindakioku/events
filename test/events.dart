class Event1 {
  void execute() {}
}

class Event2 {
  int t;

  Event2() {
    t = 2;
  }
}

class Event3 {
  void execute() {}
}

class Event3Exception {}

class Event4 {
  String data;

  Event4(this.data);
}

class Event5 {
  String data;
  int data1;

  Event5(this.data, this.data1);
}

class Event6 {
  int number;

  Event6(this.number);
}

class Event7 {
  int a;

  Event7({int number}) {
    a = number;
  }
}
