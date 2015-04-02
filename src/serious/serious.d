module serious.serious;

import serious.util;

struct serialize {
  string name;
}

alias isSerialized(alias sym) = hasAttribute!(serialize, sym);

mixin template SerializeEnable() {
  static auto deserialize(Converter, Data)(Data data, Converter conv = Converter.init) {
    import std.traits;
    import std.typetuple;
    import std.string : format;
    import serious.util;

    alias T = typeof(this);

    // default instantiate object to be populated
    T obj = construct!T;

    // iterate over each name-type pair
    foreach(name ; __traits(allMembers, T)) {
      static if (__traits(compiles, typeof(__traits(getMember, obj, name)))) {
        alias Type = typeof(__traits(getMember, obj, name));

        // look for entry matching member in the data
        if (conv.hasEntry(data, name)) {
          // entry found, convert to field type and assign to field
          auto entry = conv.getEntry(data, name);
          auto val = conv.convert!Type(entry);
          __traits(getMember, obj, name) = val;
        }
      }
    }

    return obj;
  }
}
