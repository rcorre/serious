module serious.deserialize;

import std.array     : array;
import std.string    : format;
import std.traits    : isAggregateType, isArray, isSomeString;
import std.algorithm : map;

T deserialize(T, Data, Conv)(Data data, Conv conv) {
  static if (is(T == struct) || is(T == class)) {
    return deserializeClass!T(data, conv);
  }
  else static if (isArray!T && !isSomeString!T) {
    return deserializeArray!T(data, conv);
  }
  else {
    return deserializeBasic!T(data, conv);
  }
}

private:
T deserializeClass(T, Data, Conv)(Data data, Conv conv) {
  static assert(is(typeof(T.deserialize(data, conv)) : T),
      T.stringof ~ " does not support deserialization. Did you mixin SerializeEnable?");

  return T.deserialize(data, conv);
}

alias deserializeStruct = deserializeClass;

T deserializeArray(T, Data, Conv)(Data data, Conv conv) {
  static assert(is(typeof(conv.iterate(data))),
      Conv.stringof ~ " must define 'iterate' to support desserializing arrays");

  return conv.iterate(data).map!(x => deserialize!T(data, conv)).array;
}

T deserializeBasic(T, Data, Conv)(Data data, Conv conv) {
  static assert(is(typeof(conv.convert!T(data)) : T),
      "%s does not know how to convert %s to %s".format(Conv.stringof, Data.stringof, T.stringof));

  return conv.convert!T(data);
}
