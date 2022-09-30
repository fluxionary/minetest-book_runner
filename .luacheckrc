std = "lua51+luajit+minetest+book_runner"
unused_args = false
max_line_length = 120

stds.minetest = {
	read_globals = {
		"DIR_DELIM",
		"core",
		"dump",
		"vector",
		"nodeupdate",
		"VoxelManip",
		"VoxelArea",
		"PseudoRandom",
		"ItemStack",
		"default",
		"table",
		"math",
		"string",

		minetest = {
			fields = {
				chat_send_player = {read_only = false},
			},
			other_fields = true,
		},
	}
}

stds.book_runner = {
	globals = {
		"book_runner",
	},
	read_globals = {
		"futil",
	},
}
