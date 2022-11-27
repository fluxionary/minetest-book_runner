local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

assert(
	type(futil.version) == "number" and futil.version >= os.time({ year = 2022, month = 10, day = 24 }),
	"please update futil"
)

book_runner = {
	author = "flux",
	license = "AGPL_v3",
	version = os.time({ year = 2022, month = 9, day = 30 }),
	fork = "flux",

	modname = modname,
	modpath = modpath,
	S = S,

	has = {},

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({ modpath, ... }, DIR_DELIM) .. ".lua")
	end,
}

book_runner.dofile("command")
