# argp-standalone

This is a continuation of [Niels Möller](https://www.lysator.liu.se/~nisse/)'s
work on an argp library for systems which don't provide one themselves (most
non-GNU ones).

After noticing issues with executables built against argp-standalone 1.3, I
decided to fork it and continue the effort.

This repository is the result of making a timeline with releases 1.0 to 1.3
(obtained from [here](https://www.lysator.liu.se/~nisse/misc/)) of the original
argp-standalone, copying files from glibc 2.33 and fixing them up for
compatibility, and finally some general clean up. I commited many trivial
changes from the glibc version in order to make updating easier.

It is my expectation that this library will be useful to others. Feel free to
open an issue or make a PR.
