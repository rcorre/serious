/// Generates code in user-defined types to support conversion to and from an intermediate data
/// format.
module serious.generate;

string generateDataStruct(string[] names, string[] types)() {
  import std.string    : format, join;
  import std.range     : zip;
  import std.algorithm : map;

  enum structFormat = "static struct SeriousData { %s }";

  enum memberFormat = "%s %s;";

  string members =
    zip(types, names)
    .map!(pair => memberFormat.format(pair.expand))
    .join(" ");

  return structFormat.format(members);
}

mixin template GetSerious() {
  private alias T = typeof(this);

  // names of all members that should be serialized
  private template seriousNames() {
    import std.traits    : FieldNameTuple, isSomeFunction;
    import std.typetuple : staticIndexOf, Filter;

    // true if `name` represents a non-static field
    enum isInstanceField(string name) = (staticIndexOf!(name, FieldNameTuple!T) >= 0);

    // true if `name` represents a non-static member function
    enum isInstanceMethod(string name) =
      isSomeFunction!(__traits(getMember, T, name)) &&
      !__traits(isStaticFunction, __traits(getMember, T, name));

    // true if `name` represents a non-static member field or function
    template isInstanceMember(string name) {
      static if (name == "__ctor" || name == "_fromData") {
        enum isInstanceMember = false;
      }
      else {
        enum isInstanceMember = isInstanceField!name || isInstanceMethod!name;
      }
    }

    enum seriousNames = Filter!(isInstanceMember, __traits(allMembers, T));
  }

  // type names of all members that should be serialized
  private template seriousTypeNames() {
    import std.typetuple : staticMap;

    // given a member name, get the type of that member as a string
    template getTypeName(string member) {
      enum getTypeName = typeof(__traits(getMember, T, member)).stringof;
    }

    enum seriousTypeNames = staticMap!(getTypeName, seriousNames!());
  }

  mixin(generateDataStruct!([seriousNames!()], [seriousTypeNames!()]));

  this(SeriousData data) {
    import std.string : format;
    import std.typecons : staticIota;

    foreach(member ; seriousNames!()) {
      mixin("this.%s = data.%s;".format(member, member));
    }
  }

  static T _fromData(SeriousData data) {
    import serious.util : construct;
    // construct chooses whether to use 'new' or not
    return construct!T(data);
  }
}
