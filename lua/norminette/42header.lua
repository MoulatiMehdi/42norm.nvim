-- Initialize header configuration
local M = {}

local config = {
	asciiart = {
		"        :::      ::::::::",
		"      :+:      :+:    :+:",
		"    +:+ +:+         +:+  ",
		"  +#+  +:+       +#+     ",
		"+#+#+#+#+#+   +#+        ",
		"     #+#    #+#          ",
		"    ###   ########.fr    ",
	},
	start = "/*",
	finish = "*/",
	fill = "*",
	length = 80,
	margin = 5,
	types = {
		["%.c$|%.h$|%.cc$|%.hh$|%.cpp$|%.hpp$|%.php"] = { "/*", "*/", "*" },
		["%.htm$|%.html$|%.xml$"] = { "<!--", "-->", "*" },
		["%.js$"] = { "//", "//", "*" },
		["%.tex$"] = { "%", "%", "*" },
		["%.ml$|%.mli$|%.mll$|%.mly$"] = { "(*", "*)", "*" },
		["%.vim$|vimrc$"] = { '"', '"', "*" },
		["%.el$|emacs$"] = { ";", ";", "*" },
		["%.f90$|%.f95$|%.f03$|%.f$|%.for$"] = { "!", "!", "/" },
	},
}

-- Helper functions
local function filetype()
	local f = vim.fn.expand("%:t")

	for pattern, style in pairs(config.types) do
		if f:match(pattern) then
			config.start, config.finish, config.fill = table.unpack(style)
			return
		end
	end
end

local function ascii(n)
	return config.asciiart[n - 2]
end

local function textline(left, right)
	left = left or ""
	right = right or ""
	local left_str = vim.fn.strpart(left, 0, config.length - config.margin * 2 - #right)
	return config.start
		.. string.rep(" ", config.margin - #config.start)
		.. left_str
		.. string.rep(" ", config.length - config.margin * 2 - #left_str - #right)
		.. right
		.. string.rep(" ", config.margin - #config.finish)
		.. config.finish
end

local function line(n)
	if n == 1 or n == 11 then
		return config.start
			.. " "
			.. string.rep(config.fill, config.length - #config.start - #config.finish - 2)
			.. " "
			.. config.finish
	elseif n == 2 or n == 10 then
		return textline("", "")
	elseif n == 3 or n == 5 or n == 7 then
		return textline("", ascii(n))
	elseif n == 4 then
		return textline(vim.fn.expand("%:t"), ascii(n))
	elseif n == 6 then
		return textline(
			"By: "
				.. (vim.g.user42 or os.getenv("USER") or "marvin")
				.. " <"
				.. (vim.g.mail42 or os.getenv("MAIL") or "marvin@42.fr")
				.. ">",
			ascii(n)
		)
	elseif n == 8 then
		return textline(
			"Created: "
				.. vim.fn.strftime("%Y/%m/%d %H:%M:%S")
				.. " by "
				.. (vim.g.user42 or os.getenv("USER") or "marvin"),
			ascii(n)
		)
	elseif n == 9 then
		return textline(
			"Updated: "
				.. vim.fn.strftime("%Y/%m/%d %H:%M:%S")
				.. " by "
				.. (vim.g.user42 or os.getenv("USER") or "marvin"),
			ascii(n)
		)
	end
end

function M.insert()
	local l = 11
	vim.fn.append(0, "")
	while l > 0 do
		vim.fn.append(0, line(l))
		l = l - 1
	end
end

function M.update()
	filetype()
	if vim.fn.getline(9):match(config.start .. string.rep(" ", config.margin - #config.start) .. "Updated: ") then
		if vim.bo.modified then
			vim.fn.setline(9, line(9))
		end
		vim.fn.setline(4, line(4))
		return 0
	end
	return 1
end

function M.stdheader()
	if M.update() == 1 then
		M.insert()
	end
end

return M
