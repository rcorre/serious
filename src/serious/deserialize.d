module serious.deserialize;

import std.array     : array;
import std.range     : isInputRange, ElementType;
import std.string    : format;
import std.traits    : isAggregateType, isArray, isSomeString, hasMember;
import std.algorithm : map;

T deserialize(T, D)(D data) {
  static if (is(T == struct) || is(T == class)) {
    return deserializeAggregate!T(data);
  }
  else static if (isInputRange!T && !isSomeString!T) {
    return deserializeRange!T(data);
  }
  else {
    return deserializePrimitive!T(data);
  }
}

T deserializeEntry(T, D)(D data, string key) {
  static assert(is(typeof(data.getEntry(key))),
      "%s does not support aggregate deserialization (no getEntry function)".format(D.stringof));

  auto entry = data.getEntry(key);
  return deserialize!T(entry);
}

private:
T deserializeAggregate(T, D)(D data) {
  static assert(hasMember!(T, "_deserialize"),
      "%s does not support deserialization. Did you mixin SerializeEnable?".format(T.stringof));

  return T._deserialize(data);
}

T deserializeRange(T, D)(D data) {
  static assert(isInputRange!(typeof(data.asRange())),
      "%s must define 'asRange' to deserialize %s".format(D.stringof, T.stringof));

  return data.asRange.map!(x => deserialize!T(x)).array;
}

T deserializePrimitive(T, D)(D data) {
  static assert(is(typeof(data.asPrimitive!T()) : T),
      "no known conversion %s.asPrimitive!%s".format(D.stringof, T.stringof));

  return data.asPrimitive!T;
}

unittest {
  import std.json;

  static struct JsonWrapper {
    private JSONValue _json;

    auto asPrimitive(T : long)() { return cast(T) _json.integer; }
    auto asRange()               { return _json.array.map!(x => JsonWrapper(x)); }
    auto getEntry(string key)    { return JsonWrapper(_json.object[key]); }
  }

  static struct S {
    int a, b;
    static S _deserialize(T)(T data) {
      return S(data.deserializeEntry!int("a"), data.deserializeEntry!int("b"));
    }
  }

  auto str = q{[
    { "a": 5, "b": 3 },
    { "a": 1, "b": 2 }
  ]};

  auto json = JsonWrapper(str.parseJSON);
  auto s = deserialize!(S[])(json);

  assert(s[0] == S(5, 3));
  assert(s[1] == S(1, 2));
}
