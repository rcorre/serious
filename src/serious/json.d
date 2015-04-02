module serious.json;

import std.json;
import std.conv;
import std.string;
import std.traits;
import std.exception;
import std.algorithm;
import std.range;

public import std.json : parseJSON;

struct JsonConverter {
  bool hasEntry(JSONValue json, string key) {
    assert(json.type == JSON_TYPE.OBJECT, "only json objects have keys");
    return (key in json.object) !is null;
  }

  JSONValue getEntry(JSONValue json, string name) {
    assert(hasEntry(json, name));
    return json.object[name];
  }

  JSONValue[] iterate(JSONValue json) {
    assert(json.type == JSON_TYPE.ARRAY, "only json arrays can be iterated");
    return json.array;
  }

  JSONValue convert(T : bool)(T val) {
    return JSONValue(val);
  }

  /// convert a string to a JSONValue
  JSONValue convert(T : string)(T val) {
    return JSONValue(val);
  }

  /// convert a floating point value to a JSONValue
  JSONValue convert(T : real)(T val) if (!is(T == enum)) {
    return JSONValue(val);
  }

  /// convert a signed integer to a JSONValue
  JSONValue convert(T : long)(T val) if (isSigned!T && !is(T == enum)) {
    return JSONValue(val);
  }

  /// convert an unsigned integer to a JSONValue
  JSONValue convert(T : ulong)(T val) if (isUnsigned!T && !is(T == enum)) {
    return JSONValue(val);
  }

  /// convert an enum name to a JSONValue
  JSONValue convert(T)(T val) if (is(T == enum)) {
    JSONValue json;
    json.str = to!string(val);
    return json;
  }

  /// convert a homogenous array into a JSONValue array
  JSONValue convert(T)(T args) if (isArray!T && !isSomeString!T) {
    static if (isDynamicArray!T) {
      if (args is null) { return JSONValue(null); }
    }
    JSONValue[] jsonVals;
    foreach(arg ; args) {
      jsonVals ~= convert(arg);
    }
    JSONValue json;
    json.array = jsonVals;
    return json;
  }

  private void enforceJsonType(T)(JSONValue json, JSON_TYPE[] expected ...) {
    enum fmt = "convert!%s expected json type to be one of %s but got json type %s. json input: %s";
    enforce(expected.canFind(json.type), format(fmt, typeid(T), expected, json.type, json));
  }

  /// convert a boolean from a json value
  T convert(T : bool)(JSONValue json) {
    if (json.type == JSON_TYPE.TRUE) {
      return true;
    }
    else if (json.type == JSON_TYPE.FALSE) {
      return false;
    }
    enforce(0, format("tried to convert bool from json of type %s", json.type));
    assert(0);
  }

  /// convert a string type from a json value
  T convert(T : string)(JSONValue json) {
    if (json.type == JSON_TYPE.NULL) { return null; }
    enforceJsonType!T(json, JSON_TYPE.STRING);
    return cast(T) json.str;
  }

  /// convert a numeric type from a json value
  T convert(T : real)(JSONValue json) if (!is(T == enum)) {
    switch(json.type) {
      case JSON_TYPE.FLOAT:
        return cast(T) json.floating;
      case JSON_TYPE.INTEGER:
        return cast(T) json.integer;
      case JSON_TYPE.UINTEGER:
        return cast(T) json.uinteger;
      case JSON_TYPE.STRING:
        enforce(json.str.isNumeric, format("tried to convert %s from json string %s", T.stringof, json.str));
        return to!T(json.str); // try to parse string as int
      default:
        enforce(0, format("tried to convert %s from json of type %s", T.stringof, json.type));
    }
    assert(0, "should not be reacheable");
  }

  /// convert an enumerated type from a json value
  T convert(T)(JSONValue json) if (is(T == enum)) {
    enforceJsonType!T(json, JSON_TYPE.STRING);
    return to!T(json.str);
  }

  /// convert an array from a JSONValue
  T convert(T)(JSONValue json) if (isArray!T && !isSomeString!(T)) {
    if (json.type == JSON_TYPE.NULL) { return T.init; }
    enforceJsonType!T(json, JSON_TYPE.ARRAY);
    alias ElementType = ForeachType!T;
    T vals;
    foreach(idx, val ; json.array) {
      static if (isStaticArray!T) {
        vals[idx] = this.convert!ElementType(val);
      }
      else {
        vals ~= this.convert!ElementType(val);
      }
    }
    return vals;
  }

  /// convert an associative array from a JSONValue
  T convert(T)(JSONValue json) if (isAssociativeArray!T) {
    assert(is(KeyType!T : string), "toJSON requires string keys for associative array");
    if (json.type == JSON_TYPE.NULL) { return null; }
    enforceJsonType!T(json, JSON_TYPE.OBJECT);
    alias ValType = ValueType!T;
    T map;
    foreach(key, val ; json.object) {
      map[key] = convert!ValType(val);
    }
    return map;
  }

  JSONValue getField(in JSONValue json, in string key) {
    assert(json.type == JSON_TYPE.OBJECT, "getField requires a json object");
    return json.object[key];
  }

  void setField(JSONValue json, in string key, JSONValue val) {
    assert(json.type == JSON_TYPE.OBJECT, "getField requires a json object");
    json.object[key] = val;
  }
}
