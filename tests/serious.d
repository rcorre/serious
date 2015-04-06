module tests.serious;

import std.json;
import serious.json;
import tests.types;

version (unittest) {
}
else {
  static assert(0, "Do not include tests dir unless in unit-test mode!");
}

/// Simple structs
unittest {
  void test(T)() {
    auto json = `{ "i" : 1, "b": false, "f": 0.5, "s": "wat" }`.parseJSON;

    auto obj = T._deserialize(json);
    assert(getField!"i"(obj) == 1);
    assert(getField!"b"(obj) == false);
    assert(getField!"f"(obj) == 0.5f);
    assert(getField!"s"(obj) == "wat");
  }

  test!SimpleStruct;
  //test!MemberProtection;
}
