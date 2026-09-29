--====================================================================--
-- spec/lua_class_spec.lua
--
-- Testing for lua-class using Busted
--====================================================================--


package.path = './dmc_lua/?.lua;' .. package.path


--====================================================================--
--== Test: Lua Class
--====================================================================--


-- Semantic Versioning Specification: http://semver.org/

local VERSION = "0.2.1"



--====================================================================--
--== Imports


local LuaClass = require 'lua_class'



--====================================================================--
--== Setup, Constants


-- setup some aliases to make code cleaner
local Class = LuaClass.Class
local Object = LuaClass.Object



--====================================================================--
--== Testing Setup
--====================================================================--


--[[
Test methods and such on items inside of Lua Class
--]]
describe( "Module Test: test Lua Class availability", function()

	it( "has Class name", function()
		assert( Class.NAME == "Class Class" )
	end)

	it( "has constructor function", function()
		assert( Class.new ~= nil )
		assert( type( Class.new ) == 'function' )
	end)

	it( "has method isa", function()
		assert( rawget( Class, 'isa' ) ~= nil )
	end)

	it( "has newClass access", function()
		assert( LuaClass.newClass == _G.newClass, "mismatch of newClass() functions" )
	end)

end)




--[[
Test the simplest class ever
--]]
describe( "Module Test: simplest class", function()

	local Class

	before_each( function()
		Class = newClass()
	end)

	after_each( function()
		Class = nil
	end)

	describe( "Test: simplest class elements", function()

		it( "returns a Class object", function()
			assert( type(Class) == 'table' )
			assert( Class.is_class == true )
		end)

		it( "is a subclass", function()
			assert.are.equal( Class:isa( Class ), true )
			assert.are.equal( Class:isa( Class ), true )

			assert.are.equal( Class:isa( nil ), false )
			assert.are.equal( Class:isa( {} ), false )
		end)

		it( "has a parent", function()
			assert.are.equal( #Class.supers, 1 )
		end)

		it( "has property class", function()
			assert( Class.class == Class )
		end)

		it( "has ctor/dtor methods", function()
			assert( Class.new ~= nil )
			assert( type(Class.new) == 'function' )

			assert( Class.destroy ~= nil )
			assert( type(Class.destroy) == 'function' )
		end)


		--== Private Testing ==--

		it( "has dmc-style properties", function()
			assert( rawget( Class, '__setters' ) ~= nil )
			assert( rawget( Class, '__getters' ) ~= nil )
			assert( rawget( Class, '__parents' ) ~= nil )
		end)

	end)

end)




--[[
Test the simplest inheritance
--]]
describe( "Module Test: single ineritance class", function()

	local ParentClass, Class

	before_each( function()
		ParentClass = newClass( {}, {name='Parent'} )

		Class = newClass( ParentClass, {name='Class'} )
	end)

	after_each( function()
		Class = nil
	end)

	describe( "Test: simplest class elements", function()

		it( "returns an object", function()
			assert( type(ParentClass) == 'table' )
			assert( ParentClass.is_class == true )

			assert( type(Class) == 'table' )
			assert( Class.is_class == true )
		end)

		it( "is not a table", function()
			assert( Class:isa( Class ) == true )
			assert( Class:isa( ParentClass ) == true )
			assert( Class:isa( Class ) == true )

			assert( Class:isa( nil ) == false )
			assert( Class:isa( {} ) == false )
		end)

		it( "has property class", function()
			assert( Class.class == Class )
		end)

		it( "has ctor/dtor methods", function()
			assert( type(ParentClass.new) == 'function' )
			assert( type(ParentClass.destroy) == 'function' )

			assert( type(Class.new) == 'function' )
			assert( type(Class.destroy) == 'function' )
		end)


		--== Private Testing ==--

		it( "has dmc-style properties", function()
			assert( rawget( Class, '__setters' ) ~= nil )
			assert( rawget( Class, '__getters' ) ~= nil )
			assert( rawget( Class, '__parents' ) ~= nil )
		end)

	end)

end)




--[[
Test simple-inheritance class methods
--]]
describe( "Module Test: class methods", function()

	local ClassA
	local obj, obj2
	local p

	setup( function()
	end)

	teardown( function()
	end)

	before_each( function()
		ClassA = newClass()

		function ClassA:__new__( params )
			params = params or {}
			self:superCall( '__new__', params )
			self._params = params
		end

		function ClassA:one( num )
			return num
		end

		function ClassA:two( num )
			return num * 2
		end

		p = {one=1}

		obj = ClassA:new( p )
		obj2 = ClassA( p )

	end)

	after_each( function()
		ClassA = nil
		obj = nil
		p = nil
	end)


	describe("Test: simplest class elements", function()

		it( "created object", function()
			assert( type( obj ) == 'table' )
			assert( obj.is_class == false )
			assert( obj.is_instance == true )

			assert( type( obj2 ) == 'table' )
			assert( obj2.is_class == false )
			assert( obj2.is_instance == true )
		end)

		it( "class has methods", function()
			assert( type( ClassA.one ) == 'function' )
			assert( type( ClassA.two ) == 'function' )
		end)

		it( "can access parent methods", function()
			assert.are.equal( obj:one( 4 ), 4 )
			assert.are.equal( obj:two( 4 ), 8 )

			assert.are.equal( obj2:one( 4 ), 4 )
			assert.are.equal( obj2:two( 4 ), 8 )
		end)

		it( "has properties", function()
			assert.are.equal( obj._params, p )
			assert.are.equal( obj2._params, p )
		end)

	end)

end)




--[[
Test multiple-inheritance class methods
--]]
describe( "Module Test: class methods", function()

	local ClassA, ClassB, obj, obj2

	setup( function()
	end)

	teardown( function()
	end)

	before_each( function()


		ClassA = newClass()

		function ClassA:one( num )
			return num * 2
		end

		function ClassA:two( num )
			return num * 4
		end

		function ClassA:three( num )
			return num * 6
		end

		-- function ClassA:four( num ) end


		ClassB = newClass( ClassA )

		function ClassB:one( num )
			return num * 1
		end

		function ClassB:two( num )
			return num * 2
		end

		-- function ClassB:three( num ) end

		function ClassB:four( num )
			return num * 4
		end


		obj = ClassB:new()
		obj2 = ClassB:new()


	end)

	after_each( function()
		ClassA, ClassB = nil, nil
		obj, obj2 = nil, nil
	end)


	describe("Test: inherited class elements", function()

		it( "ClassA has methods", function()
			assert( rawget( ClassA, 'one' ) ~= nil  )
			assert( type( ClassA.one ) == 'function' )

			assert( rawget( ClassA, 'two' ) ~= nil  )
			assert( type( ClassA.two ) == 'function' )

			assert( rawget( ClassA, 'three' ) ~= nil  )
			assert( type( ClassA.three ) == 'function' )

			assert( rawget( ClassA, 'four' ) == nil  )
			assert( type( ClassA.four ) == 'nil' )
		end)

		it( "ClassB has methods", function()
			assert( rawget( ClassB, 'one' ) ~= nil )
			assert( type( ClassB.one ) == 'function' )

			assert( rawget( ClassB, 'two' ) ~= nil  )
			assert( type( ClassB.two ) == 'function' )

			assert( rawget( ClassB, 'three' ) == nil  )
			assert( type( ClassB.three ) == 'function' )

			assert( rawget( ClassB, 'four' ) ~= nil  )
			-- inherited
			assert( type( ClassB.four ) == 'function' )
		end)

		it( "created object", function()
			assert( type(obj) == 'table' )
		end)

		it( "Obj1 several parent classes", function()
			assert( obj:isa( ClassA ) == true )
			assert( obj:isa( ClassB ) == true )
			assert( obj:isa( Class ) == true )

			assert( obj:isa( nil ) == false )
			assert( obj:isa( {} ) == false )
		end)

		it( "Obj2 several parent classes", function()
			assert( obj2:isa( ClassA ) == true )
			assert( obj2:isa( ClassB ) == true )
			assert( obj2:isa( Class ) == true )

			assert( obj2:isa( nil ) == false )
			assert( obj2:isa( {} ) == false )
		end)

		it( "can access parent methods", function()
			assert.are.equal( obj:one( 4 ), 4 )
			assert.are.equal( obj:two( 4 ), 8 )
			assert.are.equal( obj:three( 4 ), 24 )
			assert.are.equal( obj:four( 4 ), 16 )
		end)

	end)

end)




--[[
Test complex multiple-inheritance class methods
--]]
describe( "Module Test: class methods", function()

	local ClassA, ClassB, ClassC, ClassD
	local obj, obj2

	before_each( function()

		ClassA = newClass()
		ClassA.NAME = "Class A"

		function ClassA:one( num )
			return num * 4
		end

		function ClassA:two( num )
			return num * 4
		end

		-- function ClassA:three( num ) end

		function ClassA:four( num )
			return num * 4
		end


		ClassB = newClass( ClassA )
		ClassB.NAME = "Class B"

		function ClassB:one( num )
			local val = self:superCall( 'one', num )
			return val * 3
		end

		-- function ClassB:two( num ) end

		function ClassB:three( num )
			-- local val = self:superCall( 'three', num )
			local val = num
			return val * 3
		end

		-- function ClassB:four( num ) end


		ClassC = newClass( ClassB )
		ClassC.NAME = "Class C"

		function ClassC:one( num )
			local val = self:superCall( 'one', num )
			return val * 2
		end

		function ClassC:two( num )
			local val = self:superCall( 'two', num )
			return val * 2
		end

		-- function ClassC:three( num ) end

		-- function ClassC:four( num ) end


		ClassD = newClass( ClassC )
		ClassD.NAME = "Class D"

		function ClassD:one( num )
			local val = self:superCall( 'one', num )
			return val * 1
		end

		-- function ClassD:two( num ) end

		function ClassD:three( num )
			local val = self:superCall( 'three', num )
			return val * 1
		end

		function ClassD:four( num )
			local val = self:superCall( 'four', num )
			return val * 1
		end


		obj = ClassD:new()

	end)

	after_each( function()
		ClassA, ClassB, ClassC, ClassD = nil, nil, nil, nil
		obj, obj2 = nil, nil
	end)


	describe("Test: complex multiple-inheritance method calls", function()

		it( "has good answers", function()
			assert.are.equal( obj:one( 4 ), 96 )
			assert.are.equal( obj:two( 4 ), 32 )
			assert.are.equal( obj:three( 4 ), 12 )
			assert.are.equal( obj:four( 4 ), 16 )
		end)

	end)

end)



--[[
Test adding and removing the global newClass()
--]]
describe( "Module Test: setNewClassGlobal()", function()

	after_each( function()
		LuaClass.setNewClassGlobal( true )
	end)

	it( "sets the global newClass on load", function()
		assert.are.equal( _G.newClass, LuaClass.newClass )
	end)

	it( "removes the global with false", function()
		LuaClass.setNewClassGlobal( false )
		assert.is_nil( _G.newClass )
	end)

	it( "sets the global again with true or no argument", function()
		LuaClass.setNewClassGlobal( false )
		LuaClass.setNewClassGlobal( true )
		assert.are.equal( _G.newClass, LuaClass.newClass )
		LuaClass.setNewClassGlobal( false )
		LuaClass.setNewClassGlobal()
		assert.are.equal( _G.newClass, LuaClass.newClass )
	end)

	it( "leaves another module's newClass alone", function()
		local other = function() end
		LuaClass.setNewClassGlobal( false )
		_G.newClass = other
		LuaClass.setNewClassGlobal( true )
		assert.are.equal( _G.newClass, other )
		LuaClass.setNewClassGlobal( false )
		assert.are.equal( _G.newClass, other )
		_G.newClass = nil
	end)

end)



--[[
Test superCall() edge cases
--]]
describe( "Module Test: superCall() edge cases", function()
	local ClassA, ClassB, obj

	before_each( function()
		ClassA = newClass( nil, { name="Class A" } )
		function ClassA:pair( a, b )
			return a, b
		end
		function ClassA:count( ... )
			return select( '#', ... )
		end

		ClassB = newClass( ClassA, { name="Class B" } )
		function ClassB:pair( a, b )
			return self:superCall( 'pair', a, b )
		end
		function ClassB:count( ... )
			return self:superCall( 'count', ... )
		end

		obj = ClassB:new()
	end)

	it( "returns nil when no class defines the method", function()
		assert.is_nil( obj:superCall( 'missing' ) )
		assert.are.equal( select( '#', obj:superCall( 'missing' ) ), 1 )
		-- and leaves no state behind
		assert.is_nil( rawget( obj, '__dmc_super' ) )
		local a, b = obj:pair( 1, 2 )
		assert.are.equal( a, 1 )
		assert.are.equal( b, 2 )
	end)

	it( "returns every value of the method", function()
		local a, b = obj:pair( 1, 2 )
		assert.are.equal( a, 1 )
		assert.are.equal( b, 2 )
		local x, y = obj:pair( nil, 2 )
		assert.is_nil( x )
		assert.are.equal( y, 2 )
	end)

	it( "still works after a caught error in a called method", function()
		local err = { message='boom' }
		function ClassA:fail( x )
			if x then error( err ) end
			return 'A'
		end
		function ClassB:fail( x )
			return self:superCall( 'fail', x )
		end
		local ok, e = pcall( obj.fail, obj, true )
		assert.is_false( ok )
		assert.are.equal( e, err ) -- the same error, unchanged
		assert.is_nil( rawget( obj, '__dmc_super' ) )
		assert.are.equal( obj:fail(), 'A' )
	end)

	it( "passes every argument, nil included", function()
		assert.are.equal( obj:count( 1, nil, 3, nil ), 4 )
		assert.are.equal( obj:count(), 0 )
	end)

end)



--[[
Test that the module leaves no globals except newClass
--]]
describe( "Module Test: globals", function()

	it( "doesn't set _extend or _optimize", function()
		local ClassA = newClass( nil, { name="Class A" } )
		local obj = ClassA:new()
		obj:optimize()
		assert.is_nil( rawget( _G, '_extend' ) )
		assert.is_nil( rawget( _G, '_optimize' ) )
	end)

end)



--[[
Test getters and setters, including ones added to a parent later
--]]
describe( "Module Test: getters and setters", function()
	local ClassA, ClassB, ClassC, obj

	before_each( function()
		ClassA = newClass( nil, { name="Class A" } )
		function ClassA.__getters:one() return 'A1:' .. tostring( self ) end
		function ClassA.__setters:one( v ) rawset( self, '_one', 'A:' .. v ) end

		ClassB = newClass( nil, { name="Class B" } )
		function ClassB.__getters:one() return 'B1' end
		function ClassB.__getters:two() return 'B2' end

		ClassC = newClass( { ClassA, ClassB }, { name="Class C" } )
		obj = ClassC:new()
	end)

	it( "finds a parent's getters and setters, the first parent first", function()
		assert.are.equal( obj.one, 'A1:' .. tostring( obj ) )
		assert.are.equal( obj.two, 'B2' )
		obj.one = 'x'
		assert.are.equal( rawget( obj, '_one' ), 'A:x' )
	end)

	it( "finds getters and setters added to a parent later", function()
		function ClassA.__getters:three() return self end
		function ClassA.__setters:three( v ) rawset( self, '_three', v ) end
		assert.are.equal( obj.three, obj )
		obj.three = 3
		assert.are.equal( rawget( obj, '_three' ), 3 )
		assert.is_nil( rawget( obj, 'three' ) )
	end)

	it( "lets a subclass override a getter", function()
		function ClassC.__getters:two() return 'C2' end
		assert.are.equal( obj.two, 'C2' )
		assert.are.equal( ClassB:new().two, 'B2' )
	end)

end)



--[[
Test constructor arguments
--]]
describe( "Module Test: constructor arguments", function()

	it( "passes every argument, nil included", function()
		local ClassA = newClass( nil, { name="Class A" } )
		function ClassA:__new__( ... )
			self.count = select( '#', ... )
			self.last = select( self.count, ... )
		end
		local obj = ClassA:new( 'x', nil )
		assert.are.equal( obj.count, 2 )
		assert.is_nil( obj.last )
	end)

end)
