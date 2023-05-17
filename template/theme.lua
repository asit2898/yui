local M = {}

local colour = require("colour")

-- special colors that can be used for guifg and guibg
local special_colors = {
	fg = true,
	bg = true,
	foreground = true,
	background = true,
	NONE = true,
	none = true,
}

-- allowed values for gui
local underlines = {
	undercurl = true,
	underline = true,
	underdouble = true,
	underdotted = true,
	underdashed = true,
}

-- allowed attributes for gui and cterm
local allowed_attrs = {
	bold = true,
	underline = true,
	undercurl = true,
	underdouble = true,
	underdotted = true,
	underdashed = true,
	inverse = true,
	reverse = true,
	standout = true,
	italic = true,
	strikethrough = true,
	nocombine = true,
	NONE = true,
}

-- indent_string indents a string by a given amount. If the string contains
-- multiple lines, then each line is indented by the given amount. If it's a
-- single line, then the indent is prepended to the string.
local function indent_string(s, indent)
	if s:find("\n") then
		local indented_lines = {}
		for line in s:gmatch("[^\n]+") do
			table.insert(indented_lines, indent .. line)
		end

		return table.concat(indented_lines, "\n")
	else
		return indent .. s
	end
end

-- This is a helper function to make a highlight group. It takes a table with the following keys:
--
--   name: the name of the highlight group
--   guifg: the foreground color
--   guibg: the background color
--   gui: the gui and cterm style of the highlight group (e.g. "bold"), can be a string or a list
--   cterm: the cterm style of the highlight group (e.g. "bold"), can be a string or a list.
--          If this is not specified, then it will be set to the same value as gui.
--   link: the name of the highlight group to link to
--   guisp: the special color to use for underlines
--
-- * If link is specified, then the other keys are ignored.
-- * If guisp is specified, then gui must be one of "underline", "undercurl", "underdouble",
--   "underdotted", or "underdashed".
-- * If guifg or guibg is "fg"/"foreground" or "bg"/"background", then the corresponding color will
--   be set to the foreground or background color of the theme.
-- * If guifg or guibg is "NONE" or "none", then the corresponding color will be set to "NONE".
--
-- The function will return a string that can be used in a vimscript file to define the highlight
-- group.
M.make_hi = function(g)
	local buf = {}

	if g.link then
		table.insert(buf, string.format("hi! link %s %s", g.name, g.link))

		for _, s in ipairs { "guibg", "guifg", "gui", "guisp", "cterm" } do
			assert(g[s] == nil, s .. " must be nil for link but was " .. tostring(g[s]))
		end
		goto done
	end

	table.insert(buf, "hi " .. g.name)

	if g.guifg then
		if special_colors[g.guifg] then
			table.insert(buf, string.format("guifg=%s ctermfg=%s", g.guifg, g.guifg))
		else
			table.insert(
				buf,
				string.format("guifg=%s ctermfg=%d", g.guifg, colour.hex_to_256(g.guifg))
			)
		end
	end

	if g.guibg then
		if special_colors[g.guibg] then
			table.insert(buf, string.format("guibg=%s ctermbg=%s", g.guibg, g.guibg))
		else
			table.insert(
				buf,
				string.format("guibg=%s ctermbg=%d", g.guibg, colour.hex_to_256(g.guibg))
			)
		end
	end

	if g.guisp then
		assert(underlines[g.gui], "guisp can only be used with gui=underline")
		table.insert(buf, "guisp=" .. g.guisp)
	end

	if g.gui then
		if type(g.gui) == "string" then
			table.insert(buf, "gui=" .. g.gui)

			if not g.cterm then
				table.insert(buf, "cterm=" .. g.gui)
			end
		else
			local attrs = {}
			for _, attr in ipairs(g.gui) do
				assert(allowed_attrs[attr], "invalid gui attribute: " .. attr)
				table.insert(attrs, attr)
			end
			table.insert(buf, "gui=" .. table.concat(attrs, ","))

			if not g.cterm then
				table.insert(buf, "cterm=" .. table.concat(attrs, ","))
			end
		end
	end

	if g.cterm then
		if type(g.cterm) == "string" then
			table.insert(buf, "cterm=" .. g.cterm)
		else
			local attrs = {}
			for _, attr in ipairs(g.cterm) do
				assert(allowed_attrs[attr], "invalid cterm attribute: " .. attr)
				table.insert(attrs, attr)
			end
			table.insert(buf, "cterm=" .. table.concat(attrs, ","))
		end
	end

	::done::
	return table.concat(buf, " ")
end

-- This is a helper function to make a highlight group blocks whose value is determined by a global
-- variable. It takes a table with the following keys:
--
--  name: the name of the global variable
--  default: the default value of the global variable
--  description: a description of what this option does. This will be used in the documentation.
--  cases: a table mapping values of the global variable to highlight groups and a description of
--         what this option value does
--  cases[rhs].description: a description of what this option value does, this will be used in the
--                          documentation
--  cases[rhs].groups: a table of highlight groups
--
--  Each value in groups can be a string or a table that can be passed to make_hi.
--  If the global variable is not equal to any of the keys in cases, then no highlight groups will
--  be defined.
--
--  The function will return a string that can be used in a vimscript file to define the highlight
--  groups.
--
--  The highlight groups will be defined in the following way:
--  let s:${name}_value = get(g:, '${name}', default)
--  if s:${name}_value ==? rhs1
--    hl_group1
--    hl_group2
--    ...
--  elseif s:${name}_value ==? rhs2
--    hl_group1
--    hl_group2
--    ...
--    ...
--  endif
--
--  The keys in cases will be sorted in descending order, so that the longest keys are checked first.
--  This is done to avoid Git diffs due to random key order when iterating over a table.
M.make_opt_hi = function(opt)
	local var_name_vim = opt.name .. "_value"
	local lines = {
		string.format("let s:%s = get(g:, '%s', %s)", var_name_vim, opt.name, opt.default),
	}

	-- We want to iterate over keys in a table in a predictable and stable order
	local right_hand_if_sorted = {}
	for p in pairs(opt.cases) do
		table.insert(right_hand_if_sorted, p)
	end
	table.sort(right_hand_if_sorted, function(a, b)
		return a > b
	end)

	local cond = M.Cond {}
	for _, rhs in ipairs(right_hand_if_sorted) do
		local groups = opt.cases[rhs].groups

		table.insert(cond, M.And { string.format("s:%s ==? %s", var_name_vim, rhs) })

		local value = {}
		for _, hl_group in ipairs(groups) do
			table.insert(value, type(hl_group) == "string" and hl_group or M.make_hi(hl_group))
		end

		table.insert(cond, table.concat(value, "\n"))
	end

	table.insert(lines, tostring(cond))

	return table.concat(lines, "\n")
end

-- make_term takes a table of 16 colors and returns a string that can be used in a vimscript file
-- to define the terminal colors. The colors should be in the format #RRGGBB.
--
-- The returned string will be in the following format:
--
-- if (has('nvim'))
--  let g:terminal_color_0 = '#RRGGBB'
--  ...
-- else
-- let g:terminal_ansi_colors = [
--   \'#RRGGBB',
--   ...]
-- endif
M.make_term = function(term_colors)
	local nvim, vim = {}, { "let g:terminal_ansi_colors = [" }
	for i, color in ipairs(term_colors) do
		table.insert(nvim, string.format("let g:terminal_color_%d = '%s'", i - 1, color))
		local is_last = i == #term_colors
		table.insert(vim, string.format("\t\\'%s'%s", color, (is_last and "]" or ",")))
	end

	local cond = M.Cond {
		M.And { "has('nvim')" },
		table.concat(nvim, "\n"),
		table.concat(vim, "\n"),
	}

	return tostring(cond)
end

-- make_lightline takes a table of key/value pairs and returns a table of strings that can be used
-- in a vimscript file to define the lightline colors.
-- The keys in the table should be in the format {mode}.{name}, where mode is the lightline mode
-- (e.g. normal, insert, visual) and name is the lightline component (e.g. left, right, error).
-- The value should be a table of tables, where each inner table contains the foreground color,
-- background color, and style (optional).
M.make_lightline = function(config)
	local lightline_lines = {}

	-- We want to iterate over keys in a table in a predictable and stable order
	-- to avoid Git diffs due to random key order when iterating over a table.
	local config_keys = {}
	for k in pairs(config) do
		table.insert(config_keys, k)
	end

	table.sort(config_keys, function(a, b)
		return a > b
	end)

	for _, mode in ipairs(config_keys) do
		local part = config[mode]

		local names = {}
		for name in pairs(part) do
			table.insert(names, name)
		end

		-- Sort the names so that the lightline colors are defined in a predictable order
		-- to avoid Git diffs due to random key order when iterating over a table.
		table.sort(names, function(a, b)
			return a > b
		end)

		for _, name in ipairs(names) do
			local lightline_groups = part[name]
			table.insert(lightline_lines, string.format("let s:p.%s.%s = [", mode, name))

			for _, colors in ipairs(lightline_groups) do
				local fg, bg, style = table.unpack(colors)
				local fg_code, bg_code = colour.hex_to_256(fg), colour.hex_to_256(bg)

				local line
				if style ~= nil then
					line = string.format(
						"\t\\['%s', '%s', %d, %d, '%s'],",
						fg,
						bg,
						fg_code,
						bg_code,
						style
					)
				else
					line = string.format("\t\\['%s', '%s', %d, %d],", fg, bg, fg_code, bg_code)
				end

				table.insert(lightline_lines, line)
			end

			table.insert(lightline_lines, "\t\\]")
		end
	end

	local out = {
		"let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}",
	}

	for _, line in ipairs(lightline_lines) do
		table.insert(out, line)
	end

	table.insert(out, "let g:lightline#colorscheme#yui#palette = s:p")

	return out
end

-- make_theme takes as arguments a list of terminal colors, option groups and
-- blocks of highlight groups. A block is table with a 'name', 'groups' and
-- optional 'features' field. The returned string will be in the following
-- format:
--
-- " block_name
-- hi ...
-- hi ...
--
-- The option groups are sorted by name to avoid unnecessary Git diffs.
--
-- The 'features' field should use the Lua conditional primitives.
-- Highlight groups are sorted by name as a convention only. The first
-- highlight group in the first block must be Normal.
M.make_theme = function(term_colors, option_groups, highlight_blocks)
	local out = {
		[[
set background=light

if !has('gui_running') && &t_Co < 256 && !has('nvim')
  finish
endif

hi clear
if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'yui'
  ]],
	}

	table.insert(out, M.make_term(term_colors))
	table.insert(out, "")

	for _, block in ipairs(highlight_blocks) do
		table.insert(out, string.format('" %s', block.name))
		table.sort(block.groups, function(a, b)
			if "Normal" == a.name then
				return true
			elseif "Normal" == b.name then
				return false
			end
			return a.name < b.name
		end)

		local hl_groups = {}
		for _, group in ipairs(block.groups) do
			table.insert(hl_groups, M.make_hi(group))
		end

		if block.features ~= nil then
			local cond = M.Cond {
				block.features:map(function(s)
					return "has('" .. s .. "')"
				end),
				table.concat(hl_groups, "\n"),
			}
			table.insert(out, tostring(cond))
		else
			table.insert(out, table.concat(hl_groups, "\n"))
		end

		table.insert(out, "")
	end

	for _, opt in ipairs(option_groups) do
		table.insert(out, string.format('" %s', opt.name))
		table.insert(out, M.make_opt_hi(opt))
		table.insert(out, "")
	end

	return table.concat(out, "\n")
end

-- Generate the Vim help text for the given option groups. Each option group is a table
-- with various fields. The fields that are used to generate the docs are:
--  - name: The name of the option group
--  - description: A description of the option group
--  - default: The default value of the option group
--  - cases: A table of tables which contains the value and description of each
--           option in the group
-- Each option group is converted into a Vim help section. The section name is the name.
-- The description is used as the section description. The default value is used as the
-- default value for the option group. Each option in the group is converted into a
-- Vim help sub-section. The sub-section name is the value of the option. The description
-- is used as the sub-section description.
M.make_docs = function(option_groups)
	local line_length = 78
	local docs = {
		-- Generate a line that consists of the following:
		-- 1. The string "*yui.txt*"
		-- 2. As many spaces as necessary to make the line 78 characters long
		-- 3. The string "A minimal colorscheme for Vim and Neovim"
		string.format(
			"*yui.txt*%sA minimal colorscheme for Vim and Neovim",
			string.rep(" ", line_length - 9 - 40)
		),
		"",
		"YUI | ユイ",
		"",
	}
	table.insert(docs, string.format("%s", string.rep("=", line_length)))

	-- insert the word OPTIONS, then as many spaces as necessary, then the
	-- string '*yui-options*', so that the entire line is 78 characters
	-- long. This is the format that Vim expects for help tags.
	table.insert(
		docs,
		string.format("OPTIONS%s%s", string.rep(" ", line_length - 8 - 12), "*yui-options*")
	)
	table.insert(docs, "")

	for i, group in ipairs(option_groups) do
		if i ~= 1 then
			table.insert(docs, string.rep("-", line_length))
		end

		local option_tag_format_string = "%" .. line_length .. "s"
		local vim_tag = string.format("*g:%s*", group.name)
		table.insert(docs, string.format(option_tag_format_string, vim_tag))
		table.insert(docs, "")

		-- Headings are done by appending a tilde to the end of the line. In :h help-writing,
		-- this is described as a Column heading.
		table.insert(docs, string.format("g:%s~", group.name))
		table.insert(docs, "")

		-- If the option group has a field named "deprecated", then that field
		-- should be a string that contains the reason why the option group is
		-- deprecated. If the option group is deprecated, then add a note to the
		-- help text.
		if group.deprecated ~= nil then
			table.insert(docs, string.format("DEPRECATED: %s\n", group.deprecated))
		end

		table.insert(docs, group.description)
		-- Insert each case of the option group including the value and description
		-- of the option. Sort the cases by their key, to avoid unnecessary diffs.
		local case_keys = {}
		for key, _ in pairs(group.cases) do
			table.insert(case_keys, key)
		end
		table.sort(case_keys)

		for _, key in ipairs(case_keys) do
			local case = group.cases[key]
			local key_str = tostring(key)
			local is_default = key == group.default
			local description = case.description
			if is_default then
				description = string.format("%s (default)", description)
			end
			local line = string.format(
				"* %s:%s%s",
				key_str,
				string.rep(" ", line_length - 4 - #key_str - #description),
				description
			)
			table.insert(docs, line)
		end

		table.insert(docs, "")
		-- If the option group does not have a field called "example",
		-- then the example is generated from the name of the option group,
		-- and the default case. The example is a string that can be used
		-- to set the option group in Vim.
		local example = group.example
		if example == nil then
			example = string.format(
				[[Example: >
  let g:%s = %s
<]],
				group.name,
				group.default
			)
		else
			example = string.format(
				[[Example: >
%s
<]],
				example
			)
		end
		table.insert(docs, example)
		table.insert(docs, "")
	end

	-- Without the additional space, the modeline isn't recognized.
	-- Adding the space in the string literal doesn't work, since Vim/Neovim
	-- will then parse the modeline and fail on the closing quote and parenthesis.
	table.insert(docs, " " .. "vim:tw=78:et:ft=help:norl:")
	return table.concat(docs, "\n")
end

-- Lua Conditional Expressions
-- The following code creates Lua data structures that represent Vim
-- conditionals. I don't have much experience with Lua OOP and/or composition.
-- I'm this code can be improved by extracting some shared functionality into a
-- separate class.

-- Map a function over each condition and return a new instance of the same
-- type. The function is invoked recursively on any nested conditions.
local conditional_map = function(self, fn)
	local out = {}
	for _, arg in ipairs(self) do
		if type(arg) == "table" then
			table.insert(out, arg:map(fn))
		else
			table.insert(out, fn(arg))
		end
	end
	setmetatable(out, getmetatable(self))
	return out
end

local And = {}
M.And = And

-- This is the metatable of every instance of And.
local and_mt = {
	__tostring = function(self)
		local out = {}
		for _, arg in ipairs(self) do
			table.insert(out, tostring(arg))
		end
		return "(" .. table.concat(out, " && ") .. ")"
	end,
	__index = And,
}

-- We need to assign this to the base class so that we can
-- call the table as a function.
setmetatable(And, {
	__call = function(self, ...)
		return self:new(...)
	end,
})

function And:new(init)
	local t = {}
	for _, v in ipairs(init) do
		table.insert(t, v)
	end
	setmetatable(t, and_mt)
	return t
end

function And:map(fn)
	return conditional_map(self, fn)
end

local Or = {}
M.Or = Or

local or_mt = {
	__tostring = function(self)
		local out = {}
		for _, arg in ipairs(self) do
			table.insert(out, tostring(arg))
		end
		return "(" .. table.concat(out, " || ") .. ")"
	end,
	__index = Or,
}

setmetatable(Or, {
	__call = function(cls, ...)
		return cls:new(...)
	end,
})

function Or:new(init)
	local t = {}
	for _, v in ipairs(init) do
		table.insert(t, v)
	end
	setmetatable(t, or_mt)
	return t
end

function Or:map(fn)
	return conditional_map(self, fn)
end

local Cond = {}
M.Cond = Cond

local cond_mt = {
	__tostring = function(self)
		assert(#self >= 2, "Conditionals must have at least two arguments")
		local out = {}
		for i = 1, #self, 2 do
			if i == #self then
				local value = self[i]
				table.insert(out, "else")
				table.insert(out, indent_string(value, "\t"))
				break
			end

			local prefix = "if"
			if i > 1 then
				prefix = "elseif"
			end
			local condition, value = self[i], self[i + 1]
			table.insert(out, string.format("%s %s", prefix, condition))
			table.insert(out, indent_string(value, "\t"))
		end
		table.insert(out, "endif")
		return table.concat(out, "\n")
	end,
	__index = Cond,
}

setmetatable(Cond, {
	__call = function(cls, ...)
		return cls:new(...)
	end,
})

function Cond:new(init)
	local t = {}
	for _, v in ipairs(init) do
		table.insert(t, v)
	end
	setmetatable(t, cond_mt)
	return t
end

function Cond:map(fn)
	return conditional_map(self, fn)
end

return M
