# Development

How lua-class is tested, where it is used, and what could change.

## Testing

The tests are in `spec/lua_class_spec.lua` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`); they pass under Lua 5.4 too. From the repository's root folder:

```sh
busted spec
```

```text
+++++++++++++++++++++++++++++WARNING: newClass exists in global namespace
WARNING: newClass exists in global namespace
++++++++++
39 successes / 0 failures / 0 errors / 0 pending : 0.006935 seconds
```

The two warnings come from the test that `setNewClassGlobal()` leaves another module's global `newClass` alone.

They cover the root class's members, a simple class, single and multiple inheritance, `superCall()` through several levels and its edge cases (`nil` arguments, several return values, a method no class defines, a caught error), getters and setters (including ones added to a parent later), constructor arguments, `setNewClassGlobal()`, and that the module sets no other globals. They don't cover the other constructor names or `optimize()`.

## Where Copies Go

Other repositories carry copies of `dmc_lua/lua_class.lua`. Fix it here, then update them:

- [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies it into `dmc_lua/` with its Snakemake build (the `Snakefile` here registers the module for it), and every DMC Solar2D library copies it from there into `dmc_corona/lib/dmc_lua/`.
- lua-bytearray, lua-e4x, lua-error, lua-files, lua-megaphone, [lua-objects](https://github.com/dmccuskey/lua-objects) and lua-promise keep a copy in their own `dmc_lua/` for their tests, updated by hand.

## Possible Future Changes

Each needs discussion and a concrete use case before it is worked on.

- Tests for `registerCtorName()` and `optimize()`.
