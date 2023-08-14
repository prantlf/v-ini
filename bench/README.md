# Benchmarks

The package `prantlf.ini` stands out, `prantlf.ini2` is the second generation:

    ❯ ./bench/bench-ini.vsh
     SPENT   134.792 ms in prantlf.ini writeable
     SPENT    24.514 ms in prantlf.ini readable
     SPENT   509.239 ms in toml
     SPENT   119.022 ms in prantlf.json
     SPENT   440.735 ms in prantlf.ini writeable get directly
     SPENT   176.653 ms in prantlf.ini writeable get methods
     SPENT    68.469 ms in prantlf.ini readable get

I run the benchmarks without the compiler optimisation too. While it doesn't make sense for microbenchmarks, it allowed compiling packages, which aren't maintained so often. The packages `prantlf.ini` and `ldedev.ini` stand out:

    ❯ ./bench/bench-ini.vsh
     SPENT  280.369 ms in prantlf.ini
     SPENT   80.387 ms in prantlf.ini2
     SPENT 1464.245 ms in toml
     SPENT 1229.017 ms in spytheman.vini
     SPENT  521.827 ms in ldedev.ini
     SPENT  289.894 ms in prantlf.json
     SPENT 1072.737 ms in prantlf.ini get directly
     SPENT  478.688 ms in prantlf.ini get methods
     SPENT  316.194 ms in prantlf.ini2 get
