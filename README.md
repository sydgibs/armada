# Recovery refinement

[![Build Status](https://travis-ci.org/mit-pdos/argosy.svg?branch=master)](https://travis-ci.org/mit-pdos/argosy)

Proving crash safety of systems by proving an implementation refines a specification. Supports implementations that run a recovery procedure, as well as abstracting away the behavior of the recovery procedure.

## Compiling

We stick to the master branch of Coq, which is currently v8.10. Unfortunately there's an incompatibility and we're sticking with warning-free code compatible with Coq master.

This project uses a git submodule to include [Tactical](https://github.com/tchajed/coq-tactical) as a dependency. You can either use `git clone --recurse-submodules` or (after cloning) `git submodule --init --recursive` to set that up.

To compile just run `make` with Coq on your `$PATH`.
