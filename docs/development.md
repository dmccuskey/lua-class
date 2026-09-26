# Development

How lua-class is tested, where it is used, and what could change.

## Testing

The tests are in `spec/lua_class_spec.lua` and use [busted](https://lunarmodules.github.io/busted/) under Lua 5.1 (`luarocks install busted`). From the repository's root folder:

```sh
busted spec
```

```text
++++++++++++++++++++++++++
26 successes / 0 failures / 0 errors / 0 pending : 0.008715 seconds
```

They cover the root class's members, a simple class, single and multiple inheritance, and `superCall()` through several levels. They don't cover getters and setters, the other constructor names, or `optimize()`.

## Where Copies Go

Other repositories carry copies of `dmc_lua/lua_class.lua`. Fix it here, then update them:

- [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) copies it into `dmc_lua/` with its Snakemake build (the `Snakefile` here registers the module for it), and every DMC Solar2D library copies it from there into `dmc_corona/lib/dmc_lua/`.
- [lua-objects](https://github.com/dmccuskey/lua-objects) keeps a copy in its own `dmc_lua/` for its tests, updated by hand.

## Possible Future Changes

Each needs discussion and a concrete use case before it is worked on.

- Run under Lua 5.2 and later (`local unpack = unpack or table.unpack`).
- Tests for getters and setters, `registerCtorName()` and `optimize()`, and for the [known issues](api.md#known-issues) once they are fixed.
