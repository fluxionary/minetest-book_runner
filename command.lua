local S = default.get_translator

minetest.register_chatcommand("run_in_book", {
	params = "<command> [<args>]",
	description = "run the command; put the output in the book's body",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "you are not a player"
		end

		local wielded_item = player:get_wielded_item()
		if wielded_item:get_name() ~= "default:book" or wielded_item:get_count() ~= 1 then
			return false, "you must be holding exactly one unwritten book item (default:book)"
		end

		local command, args = param:match("^%s*(%S+)%s+(.*)$")
		if not (command and args) then
			command = param:match("^%s*(%S+)%s*$")
			args = ""
		end

		if not command then
			return false, "please provide a command as an argument"
		end

		local command_def = minetest.registered_chatcommands[command]
		if not command_def then
			return false, ("unknown command %s"):format(command)
		end

		if not minetest.check_player_privs(player, command_def.privs) then
			return false, ("you lack privileges to run %s"):format(command)
		end

		local old_chat_send_player = minetest.chat_send_player
		local received_messages = {}
		function minetest.chat_send_player(name2, message)
			if name == name2 then
				table.insert(received_messages, minetest.strip_colors(futil.strip_translation(message)))

			else
				old_chat_send_player(name2, message)
			end
		end

		local _, status = command_def.func(name, args)
		if status and status ~= "" then
			table.insert(received_messages, minetest.strip_colors(futil.strip_translation(status)))
		end

		minetest.chat_send_player = old_chat_send_player

		local text = table.concat(received_messages, "\n")
		local written_book = ItemStack("default:book_written")
		written_book:get_meta():from_table({fields = {
			title = param,
			owner = name,
			description = S("\"@1\" by @2", param, name),
			text = text,
			page = 1,
			page_max = math.ceil((#text:gsub("[^\n]", "") + 1) / 14)
		}})

		player:set_wielded_item(written_book)

		return true, "book written"
	end,
})
