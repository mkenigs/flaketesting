Flakes have dependencies that are represented as a directed graph, which means multiple flakes can depend on the same flake. The command `nix flake list-inputs` lists those dependencies. I added support for circular dependencies here: https://github.com/NixOS/nix/pull/3607. But `list-inputs` also has a `--json` option.  If you run the `./test.sh` script (you might need to adjust the `NIX` variable to point to the path where you built nix) you should see output for `list-input` and `list-input --json`. With `--json`, if multiple flakes depend on the same input, that input is duplicated in the output, in this case `nixpkgs` and `nixpkgs_2`. You should be able to fix that by modifying the code for `--json` which is in `src/libexpr/flake/lockfile.cc::LockFile::toJson()`. You might be able to do something somewhat similar to what I did in https://github.com/NixOS/nix/pull/3607.