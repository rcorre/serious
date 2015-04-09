/// Types defined for unit testing.
module tests.types;

import serious.generate;

version (unittest) {
}
else {
  static assert(0, "Do not include tests dir unless in unit-test mode!");
}

/// Helper to check private fields in tests.
auto getField(string name, T)(in T obj) {
  import std.string : format;
  mixin("return obj.%s;".format(name));
}

/// Helper to set private fields in tests.
auto setField(string name, T, V)(ref T obj, in V val) {
  import std.string : format;
  mixin("obj.%s = val;".format(name));
}

struct StructSimple {
  mixin GetSerious;

  int    i;
  bool   b;
  float  f;
  string s;
}

struct StructPrivate {
  mixin GetSerious;

  private:
  int    i;
  bool   b;
  float  f;
  string s;
}

/*
struct StructProps {
  mixin GetSerious;

  @property {
    // getters
    auto i() { return _i; }
    auto b() { return _b; }
    auto f() { return _f; }
    auto s() { return _s; }

    // setters
    void i(int val)    { _i = val; }
    void b(bool val)   { _b = val; }
    void f(float val)  { _f = val; }
    void s(string val) { _s = val; }
  }

  private:
  int    _i;
  bool   _b;
  float  _f;
  string _s;
}
*/
