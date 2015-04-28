# lua-class

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "lua-class"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "lua-class",
	"module": {
		"dir": "dmc_lua",
		"files": [
			"lua_class.lua"
		],
		"requires": []
	},
	"tests": {
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "lua-class", module_config )

