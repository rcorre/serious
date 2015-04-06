module serious.serious;

import serious.util;

struct seriousName { string name; }

struct seriousIgnore { }
struct seriousEnable { }

template isSerializeable(alias sym) {
  enum isSerializeable = true; // TODO
}

mixin template SerializeEnable() {
  static auto _deserialize(D)(D data) {
    import std.traits;
    import std.typetuple;
    import std.string : format;
    import serious.util;
    import serious.deserialize;

    alias T = typeof(this);
    template getMember(obj, name) {
      enum getMember = __traits(getMember, obj, name);
    }

    // default instantiate object to be populated
    T obj = construct!T;

    // iterate over each name-type pair
    foreach(name ; __traits(allMembers, T)) {
      static if (__traits(compiles, typeof(getMember(obj, name)))) {
        alias Type = typeof(getMember(obj, name));

        // look for entry matching member in the data
        if (conv.hasEntry(data, name)) {
          // entry found, convert to field type and assign to field
          auto entry = conv.getEntry(data, name);
          auto val = deserialize!Type(entry, conv);
          __traits(getMember, obj, name) = val;
        }
      }
    }

    return obj;
  }
}
