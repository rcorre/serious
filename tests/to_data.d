module tests.to_data;

import serious.generate;
import tests.types;

// fields only, generated constructor
unittest {
  StructSimple s;
  s.i = 5;
  s.b = true;
  s.f = 4.2f;
  s.s = "tally-ho!";

  auto data = s._toData;
  assert(data.i == 5);
  assert(data.b == true);
  assert(data.f == 4.2f);
  assert(data.s == "tally-ho!");
}

// private fields only, generated constructor
unittest {
  StructPrivate s;
  // getField is just a test helper to set private fields
  s.setField!"i"(5);
  s.setField!"b"(true);
  s.setField!"f"(4.2f);
  s.setField!"s"("tally-ho!");

  auto data = s._toData;
  assert(data.i == 5);
  assert(data.b == true);
  assert(data.f == 4.2f);
  assert(data.s == "tally-ho!");
}
