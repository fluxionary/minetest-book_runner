local f = string.format

local strip_colors = minetest.strip_colors

local strip_translation = futil.strip_translation

local S = default.get_translator

local max_book_length = book_runner.settings.max_book_length

minetest.register_chatcommand("run_in_book", {
	params = "<command> [<args>]",
	description = "run the command; put the output in the book's body",
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false, "you must be logged in to run this command"
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
			return false, f("unknown command %s", command)
		end

		if not minetest.check_player_privs(player, command_def.privs) then
			return false, f("you lack privileges to run %s", command)
		end

		local orig_chat_send_player = minetest.chat_send_player
		local length = 0
		local skipped_lines = 0
		local too_long = false
		local received_messages = {}
		function minetest.chat_send_player(name2, message)
			if name == name2 then
				if too_long then
					skipped_lines = skipped_lines + 1
				elseif length + #message + 1 > max_book_length then
					too_long = true
					skipped_lines = skipped_lines + 1
				else
					table.insert(received_messages, strip_colors(strip_translation(message)))
					length = length + #message + 1
				end
			else
				orig_chat_send_player(name2, message)
			end
		end

		book_runner.log("action", "%s runs %q", name, param)
		local _, status = command_def.func(name, args)
		if status and status ~= "" then
			table.insert(received_messages, strip_colors(strip_translation(status)))
		end

		minetest.chat_send_player = orig_chat_send_player

		if too_long then
			table.insert(received_messages, f("WARNING: too much output, %i lines omitted", skipped_lines))
		end

		local text = table.concat(received_messages, "\n")
		local written_book = ItemStack("default:book_written")
		written_book:get_meta():from_table({
			fields = {
				title = param,
				owner = name,
				description = S('"@1" by @2', param, name),
				text = text,
				page = 1,
				page_max = math.ceil((#text:gsub("[^\n]", "") + 1) / 14),
			},
		})

		player:set_wielded_item(written_book)

		return true, "book written"
	end,
})
