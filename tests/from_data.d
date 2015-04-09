module tests.from_data;

import serious.generate;
import tests.types;

// fields only, generated constructor
unittest {
  StructSimple.SeriousData data;
  data.i = 5;
  data.b = true;
  data.f = 4.2f;
  data.s = "tally-ho!";

  auto s = StructSimple._fromData(data);
  assert(s.i == 5);
  assert(s.b == true);
  assert(s.f == 4.2f);
  assert(s.s == "tally-ho!");
}

// private fields only, generated constructor
unittest {
  StructPrivate.SeriousData data;
  data.i = 5;
  data.b = true;
  data.f = 4.2f;
  data.s = "tally-ho!";

  auto s = StructPrivate._fromData(data);
  // getField is just a test helper to view private fields
  assert(getField!"i"(s) == 5);
  assert(getField!"b"(s) == true);
  assert(getField!"f"(s) == 4.2f);
  assert(getField!"s"(s) == "tally-ho!");
}
