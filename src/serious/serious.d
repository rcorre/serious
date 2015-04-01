module serious.serious;

import serious.util;

struct serialize {
  string name;
}

alias isSerialized(alias sym) = hasAttribute!(serialize, sym);

mixin template SerializeEnable(this T) {
  static T deserialize(Converter, Data)(Data data, Converter conv = conv.init) {
    import std.traits;
    import std.typetuple;

    // default instantiate object to be populated
    T obj = new T;

    // names and types of all fields
    alias MemberNames = FieldNameTuple!T;
    alias MemberTypes = FieldTypeTuple!T;

    // iterate over each name-type pair
    foreach(member ; staticIota!(0, memberNames.length)) {
      alias Name = MemberNames[i];
      alias Type = MemberTypes[i];

      // look for entry matching member in the data
      if (conv.canFindEntry(member, data)) {
        // entry found, convert to field type and assign to field
        auto val = conv.convert!Type(entry);
        __traits(getMember, obj, Name) = val;
      }
    }

    return obj;
  }
}
