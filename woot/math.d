module woot.math;

version(unittest) {
  import std.conv;
}

/// Return the smallest power of two greater or equal to the given number.
int nextPowerOfTwo(int number) {
  // Algorithm stolen from http://bits.stephan-brumme.com/roundUpToNextPowerOfTwo.html

  if (number) {
    number--;

    number |= number >> 1;
    number |= number >> 2;
    number |= number >> 4;
    number |= number >> 8;
    number |= number >> 16;

    return number + 1;
  } else {
    return 0;
  }
}

unittest {
  assert(0 == nextPowerOfTwo(0));

  auto powers = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024];
  auto last   = 1;

  foreach(power; powers) {
    foreach(number; last .. (power + 1)) {
      auto result = nextPowerOfTwo(number);

      assert(power == result, text("Expected nextPowerOfTwo(", number, ") == ", power, ", but was ", result));
    }

    last = power + 1;
  }
}
