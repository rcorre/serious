module tests.generate;

import serious.generate;
import tests.types;

/// Simple structs
unittest {
  void checkMembers(T, members ...)() {
    import std.string : format;

    foreach(member ; members) {
      static assert(__traits(hasMember, T.SeriousData, member),
          "SeriousData for %s is missing %s".format(T.stringof, member));
    }

    foreach(member ; __traits(allMembers, T.SeriousData)) {
      static assert(__traits(hasMember, T, member),
          "SeriousData for %s has extra member %s".format(T.stringof, member));
    }
  }

  checkMembers!(StructSimple,  "i", "b", "f", "s");
  checkMembers!(StructPrivate, "i", "b", "f", "s");
}
