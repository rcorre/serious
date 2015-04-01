version (unittest) {
  import serious.util;

  // mock attributes
  struct a { int i; }
  struct b { string s; }

  // void functions
  @a       void fun0() { }
  @a(3)    void fun1() { }
  @a @a(3) void fun2() { }
  @b       void fun3() { }
  @a @b    void fun4() { }
  @a @b    int  fun5(int i) { return i; }

  @a @b @a(3) struct S {
    private:
    @a    int    i;
    @a(3) float  f;
    @b    string s;

    @a    void fun()      { }
    @a(3) int  fun(int i) { return i; }

    @a @property int  prop()        { return i; }
    @a @property void prop(int val) { this.i = val; }
  }

  void assertSame(T1, T2)() {
    static assert(__traits(isSame, T1, T2));
  }
}

// findAttribute
unittest {
  // free functions
  static assert(findAttribute!(a, fun0).length == 1);
  static assert(findAttribute!(a, fun1).length == 1);
  static assert(findAttribute!(a, fun2).length == 2);
  static assert(findAttribute!(a, fun3).length == 0);
  static assert(findAttribute!(a, fun4).length == 1);
  static assert(findAttribute!(a, fun5).length == 1);

  // struct type
  static assert(findAttribute!(a, S).length == 2);

  S s;
  // struct fields
  static assert(findAttribute!(a, s.i).length == 1);
  static assert(findAttribute!(a, s.f).length == 1);
  static assert(findAttribute!(a, s.s).length == 0);

  // struct methods
  static assert(findAttribute!(a, s.fun).length == 1);
  static assert(findAttribute!(a, s.prop).length == 1);
}

unittest {
  // free functions
  static assert(hasAttribute!(a, fun0));
  static assert(hasAttribute!(a, fun1));
  static assert(hasAttribute!(a, fun2));
  static assert(!hasAttribute!(a, fun3));
  static assert(hasAttribute!(a, fun4));
  static assert(hasAttribute!(a, fun5));

  // struct type
  static assert(hasAttribute!(a, S));

  S s;
  // struct fields
  static assert(hasAttribute!(a, s.i));
  static assert(hasAttribute!(a, s.f));
  static assert(!hasAttribute!(a, s.s));

  // struct methods
  static assert(hasAttribute!(a, s.fun));
  static assert(hasAttribute!(a, s.prop));
}
