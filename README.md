# lua-class

Classes for Lua 5.1 and later: inheritance from one or several classes, getters and setters, and calls to any parent's version of a method.

It is the class model under [lua-objects](https://github.com/dmccuskey/lua-objects) (plain Lua) and [dmc-objects](https://github.com/dmccuskey/dmc-objects) (Solar2D, formerly Corona SDK). A class is a table, and so is an instance:

```lua
local Class = require 'lua_class'

local Account = Class.newClass( nil, { name="Account" } )

function Account:__new__( params )
	params = params or {}
	self._balance = params.balance or 0
end

function Account.__getters:balance()
	return self._balance
end

local account = Account:new{ balance=100 }
print( account.balance )  --> 100
```

## Features

- `newClass()` with one parent, several parents (mixins), or none
- Getters and setters: `obj.balance` and `obj.balance = 5` can run your code
- `superCall()` reaches the parents' version of a method, or one named parent's
- A constructor and destructor per class (`__new__()`, `__destroy__()`), called by `new()` and `destroy()`, and other names for them if you want (`create()`, `removeSelf()`)
- `isa()`, `is_class`, `is_instance`, `class`, `supers` and a printable class name
- `optimize()` copies inherited methods onto an object for faster lookups
- One file, pure Lua, no dependencies; MIT licensed

## Quick Start

The following code will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. It writes a class and a subclass and runs them.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/lua-class.git
```

The module is the one file `lua-class/dmc_lua/lua_class.lua`.

### 2. Write a Class

Create `main.lua` in the same folder:

```lua
package.path = './lua-class/dmc_lua/?.lua;' .. package.path
local Class = require 'lua_class'

local Account = Class.newClass( nil, { name="Account" } )

function Account:__new__( params )
	params = params or {}
	self._balance = params.balance or 0
end

function Account.__getters:balance()
	return self._balance
end

function Account:deposit( amount )
	self._balance = self._balance + amount
end

local account = Account:new{ balance=100 }
account:deposit( 25 )
print( account, account.balance, account:isa( Account ) )
```

Run it:

```sh
lua main.lua
```

```text
Account (table: 0x600001a2c040)	125	true
```

If it shows `module 'lua_class' not found`, run it from the folder that holds `lua-class/`.

**Going further:** what runs when an instance is created and destroyed ([Constructor and Destructor](docs/api.md#constructor-and-destructor)), and setters ([Getters and Setters](docs/api.md#getters-and-setters)).

### 3. Write a Subclass

Add this to the end of `main.lua`:

```lua
local SavingsAccount = Class.newClass( Account, { name="Savings Account" } )

function SavingsAccount:__new__( params )
	params = params or {}
	self:superCall( '__new__', params )
	self._rate = params.rate or 0.02
end

function SavingsAccount:deposit( amount )
	self:superCall( 'deposit', amount )
	print( 'deposited', amount )
end

function SavingsAccount:addInterest()
	self:deposit( self._balance * self._rate )
end

local savings = SavingsAccount:new{ balance=200, rate=0.05 }
savings:addInterest()
print( savings, savings.balance, savings:isa( Account ) )
```

`lua main.lua` now also shows:

```text
deposited	10
Savings Account (table: 0x600001a2c6c0)	210	true
```

`SavingsAccount` has its own `__new__()` and `deposit()`, and each calls `Account`'s with `superCall()`. Without that call, `Account:__new__()` doesn't run for a savings account.

**Going further:** several parents and mixins ([Multiple Inheritance](docs/api.md#multiple-inheritance)), or a base class with events and a longer setup sequence ([lua-objects](https://github.com/dmccuskey/lua-objects)).

To update, pull the repository again (`git -C lua-class pull`), or replace `lua_class.lua` with the newer one.

## Documentation

- [API reference](docs/api.md): `newClass()`, the constructor and destructor, class members, getters and setters, `superCall()`, multiple inheritance, known issues
- [lua-objects](https://github.com/dmccuskey/lua-objects): `ObjectBase`, a base class built on this one, with events
- [dmc-objects](https://github.com/dmccuskey/dmc-objects): classes for Solar2D display objects, built on lua-objects

Everything else is listed on the [documentation home](docs/README.md).

## License

lua-class is released under the [MIT License](LICENSE).
