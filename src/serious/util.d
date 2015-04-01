module serious.util;

import std.stdio;
import std.typetuple;
import std.typecons;

/// Get a tuple of all attributes on `sym` matching `attr`.
template findAttribute(alias attr, alias sym) {
  template match(alias a) {
    enum match = (is(a == attr) || is(typeof(a) == attr));
  }

  static if (__traits(compiles, __traits(getAttributes, sym))) {
    alias findAttribute = Filter!(match, __traits(getAttributes, sym));
  }
  else {
    alias findAttribute = TypeTuple!();
  }
}

/// True if `sym` has an attribute `attr`.
template hasAttribute(alias attr, alias sym) {
  enum hasAttribute = findAttribute!(attr, sym).length > 0;
}

/// True if `attr` has a value (e.g. it is not a type).
template isValueAttribute(alias attr) {
  enum isValueAttribute = is(typeof(attr));
}

auto getMember(string name)() {
  return (x) => __traits(getMember, x, name);
}

T construct(T, Params ...)(Params params) {
  static if (is(typeof(T(params)) == T)) {
    return T(params);
  }
  else static if (is(typeof(new T(params)) == T)) {
    return new T(params);
  }
  else {
    static assert(0, "Cannot construct");
  }
}

unittest {
  static struct Foo {
    this(int i) { this.i = i; }
    int i;
  }

  assert(construct!Foo().i == 0);
  assert(construct!Foo(4).i == 4);
  assert(!__traits(compiles, construct!Foo("asd")));
}

unittest {
  static class Foo {
    this(int i) { this.i = i; }

    this(int i, string s) {
      this.i = i;
      this.s = s;
    }

    int i;
    string s;
  }

  assert(construct!Foo(4).i == 4);
  assert(construct!Foo(4, "asdf").s == "asdf");
  assert(!__traits(compiles, construct!Foo("asd")));
}
