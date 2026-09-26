# API Reference

Everything lua-class provides, as of version 0.1.0. The [Quick Start](../README.md#quick-start) shows the pieces used together.

| name | what it is |
|---|---|
| [The module](#the-module) | what `require 'lua_class'` returns |
| [`newClass()`](#newclass) | creates a class |
| [Constructor and destructor](#constructor-and-destructor) | `__new__()` and `__destroy__()`, and what runs when |
| [Class members](#class-members) | what every class and instance has: `new()`, `destroy()`, `superCall()`, `isa()`, ... |
| [Getters and setters](#getters-and-setters) | properties that run code |
| [`superCall()`](#supercall) | calling a parent's version of a method |
| [Multiple inheritance](#multiple-inheritance) | several parents, mixins |
| [Other names for `new()` and `destroy()`](#other-names-for-new-and-destroy) | `registerCtorName()`, `registerDtorName()` |
| [Making lookups faster](#making-lookups-faster) | `optimize()`, `deoptimize()` |
| [Known issues](#known-issues) | what doesn't work as you'd expect |

## The Module

```lua
local Class = require 'lua_class'
```

`dmc_lua/lua_class.lua` has to be on `package.path` (the [Quick Start](../README.md#2-write-a-class) shows how). In [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) and the Solar2D libraries it is `lib/dmc_lua/lua_class.lua`, loaded by [lua-objects](https://github.com/dmccuskey/lua-objects).

| field | |
|---|---|
| `Class.newClass` | [`newClass()`](#newclass) |
| `Class.Class` | the root class every class inherits from; its `NAME` is `Class Class` |
| `Class.registerCtorName( name, class )`, `Class.registerDtorName( name, class )` | see [Other Names](#other-names-for-new-and-destroy) |
| `Class.inheritsFrom( parent, params )` | the old way to create a class; same as `newClass( parent, params )` |
| `Class.setNewClassGlobal()` | sets the global `newClass`, see below |
| `Class.__version` | `"0.1.0"` |

Loading the module also sets the global `newClass`. If a global `newClass` already exists, it prints `WARNING: newClass exists in global namespace` and leaves it; use `Class.newClass` in that case. That happens when the file is loaded twice under two module names.

The code is written for Lua 5.1, the version Solar2D uses: it calls the global `unpack()`, which Lua 5.2 moved to `table.unpack`.

## newClass

```lua
local MyClass = Class.newClass( parents, { name="My Class" } )
```

- `parents`: one class, a list of them (`{ Account, Printable }`, searched in that order), or `nil` for a class whose only parent is the root class. A parent can also be a plain table of functions, a mixin (see [Multiple Inheritance](#multiple-inheritance)).
- `name`: what `obj.NAME` returns and `print( obj )` shows. Default `<unnamed class>`.

Creating a class runs each parent's `__new__()` on the new class, without arguments, last parent first. So a constructor has to accept no arguments (`params = params or {}`), and the fields it sets are stored on the class too. An instance reads them from the class when it has none of its own.

## Constructor and Destructor

```lua
function Account:__new__( params )
	params = params or {}
	self._balance = params.balance or 0
end

function Account:__destroy__()
	self._balance = nil
end

local account = Account:new{ balance=100 }  -- or Account{ balance=100 }
account:destroy()
```

`MyClass:new( ... )` creates an instance, whose one parent is `MyClass`, and calls its `__new__( ... )` with the same arguments. Only one `__new__()` runs: the class's own or, if it has none, the nearest parent's. To run the parents' constructors too, call them from yours with [`superCall()`](#supercall):

```lua
function SavingsAccount:__new__( params )
	params = params or {}
	self:superCall( '__new__', params )
	self._rate = params.rate or 0.02
end
```

`obj:destroy()` calls `obj:__destroy__()` the same way: the nearest one only, so call `self:superCall( '__destroy__' )` from yours. `destroy()` doesn't empty the object or make it unusable; clear what you stored in `__destroy__()`.

The root class's `__new__()` and `__destroy__()` do nothing.

## Class Members

Every class and instance has these.

| member | |
|---|---|
| `MyClass:new( ... )` | creates an instance; the arguments go to `__new__()`. `MyClass( ... )` does the same. |
| `obj:destroy()` | calls `__destroy__()` |
| `obj:superCall( 'method', ... )` | calls the parents' version of `method` ([`superCall()`](#supercall)) |
| `obj:superCall( Parent, 'method', ... )` | the same, searching only `Parent` |
| `obj:isa( SomeClass )` | `true` if `obj` is `SomeClass`, an instance of it, or inherits from it |
| `obj:optimize()`, `obj:deoptimize()` | see [Making Lookups Faster](#making-lookups-faster) |
| `obj.NAME` | the class name given to `newClass()` |
| `obj.class` | the class of an instance (a class returns itself) |
| `obj.supers` | the list of parents: an instance's is `{ its class }` |
| `obj.is_class`, `obj.is_instance` | which of the two `obj` is. `is_intermediate` is an old name for `is_class`. |
| `obj.version` | the object's `__version` field, if you set one; lua-class doesn't |
| `MyClass.__getters`, `MyClass.__setters` | where to define [getters and setters](#getters-and-setters) |

`print( obj )` shows the name and the table address: `Savings Account (table: 0x600001a2c6c0)`.

A name lookup on an object checks, in order: the object's own fields, its getters, then its parents (each parent's own fields, getters and parents, before the next parent).

## Getters and Setters

```lua
function Account.__getters:balance()
	return self._balance
end

function Account.__setters:balance( value )
	assert( type( value )=='number', "balance must be a number" )
	self._balance = value
end

print( account.balance )  -- calls the getter
account.balance = 50      -- calls the setter
```

- Store the value under another name (`_balance`). Getters and setters only run while the object has no field of their name: once `obj.balance` is a field, reading it returns the field and assigning to it replaces the field. A property with a getter and no setter therefore stops using the getter after `obj.balance = 50`.
- Subclasses and instances get a copy of their parents' getters and setters when they are created. Define them before creating subclasses or instances (see [Known Issues](#known-issues)).
- With several parents, the first parent's getter or setter wins.

## superCall

```lua
self:superCall( 'method', ... )
self:superCall( Parent, 'method', ... )
```

`superCall()` finds the class nearest to the object that defines `method`, then calls the next `method` among that class's parents. Called from inside an override, that is the parent's version. Each override up the chain can call it again; the object keeps track of how far up it is.

With a parent as the first argument, only that parent and its own parents are searched. Use it to call a particular parent's version when there are several ([Multiple Inheritance](#multiple-inheritance)).

It returns the method's first return value only. If no parent has the method, it calls nothing and returns `nil`, but if no class defines `method` at all it raises an error (see [Known Issues](#known-issues)).

## Multiple Inheritance

```lua
local Printable = {}
function Printable:describe()
	return 'I am ' .. self.NAME
end

local Checking = Class.newClass( { Account, Printable }, { name="Checking" } )

function Checking:__new__( params )
	params = params or {}
	self:superCall( Account, '__new__', params )
	self._overdraft = params.overdraft or 0
end

local checking = Checking:new{ balance=10 }
print( checking:describe() )  --> I am Checking
```

- Parents are searched in the order listed, each one fully (its fields, getters and parents) before the next.
- A parent can be a class or a plain table of functions (a mixin, like `Printable` here). [lua-objects](https://github.com/dmccuskey/lua-objects)' `ObjectBase` is built this way, from the root class and the events mixin from [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin).
- An instance runs one `__new__()`, the nearest. Call each parent's that you need with `superCall( Parent, '__new__', ... )`, as above. A mixin usually has a setup function of its own for this (lua-events-mixin's is `__init__()`).
- `isa()` checks every parent that is a class; a plain-table parent isn't one, so `checking:isa( Printable )` is `false`.

## Other Names for new() and destroy()

```lua
Class.registerCtorName( 'create', Account )      -- Account:create{ ... }
Class.registerDtorName( 'removeSelf', Account )  -- account:removeSelf()
```

Adds another name for the constructor or destructor on `class` (default: the root class, so every class gets it). Subclasses of `class` have it too. lua-objects registers `removeSelf` this way, to match Solar2D's display objects.

## Making Lookups Faster

`obj:optimize()` copies every method that `obj` inherits onto `obj` itself, so calls no longer search the parents. The nearest definition of each wins, as in a normal lookup. Use it on an object whose methods won't change afterwards, in code that runs often.

`obj:deoptimize()` removes every function stored on `obj`, including any you stored there yourself.

## Known Issues

- **Getters and setters added to a parent after a subclass or instance exists** aren't copied to it: such a setter never runs, and such a getter runs with the parent class as `self`, not the object.
- **`superCall( 'method' )` raises an error when no class defines `method`** (`attempt to index local 'c' (a nil value)`), instead of returning `nil`.
- `superCall()` returns only the first of the method's return values.
- `Class.setNewClassGlobal( false )` doesn't remove the global `newClass`: it prints the warning above and leaves it.
- The module sets the globals `_extend` (when a class or instance is created) and `_optimize` (on the first `optimize()`).
