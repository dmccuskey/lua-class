# lua-class Documentation

New here? The [Quick Start](../README.md#quick-start) writes a class and a subclass and runs them in about 5 minutes.

## Start

- [Quick Start](../README.md#quick-start): get the code, write a class, write a subclass

## Use

- [API reference](api.md): `newClass()`, the constructor and destructor, class members, getters and setters, `superCall()`, multiple inheritance, known issues
- [lua-objects](https://github.com/dmccuskey/lua-objects): `ObjectBase`, a base class with events and a setup and teardown sequence, built on this one
- [dmc-objects](https://github.com/dmccuskey/dmc-objects): classes for Solar2D display objects, built on lua-objects

## Contribute

- [Development](development.md): tests, where copies of the module go, possible future changes
- [Issues](https://github.com/dmccuskey/lua-class/issues)

## Project Structure

```text
README.md               landing page and Quick Start
LICENSE
docs/                   this documentation
dmc_lua/
└── lua_class.lua       the module
Snakefile               build rules, for DMC-Lua-Library
spec/
└── lua_class_spec.lua  tests (busted)
```
