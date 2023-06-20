local Theme = require("theme")
local Lightline = require("lightline")
local HLGroup = require("hlgroup")
local TerminalColors = require("terminal_colors")
local ThemeOption = require("option").ThemeOption
local Cond = require("condition")
local lighten = require("colour").lightness

local colors = {
	black = "#5f503e",
	white = "#efeae5",
	accent = "#dcd7f9",
	dark_blue = "#1E5571",
	light_blue = "#E7F4F8",
	dark_green = "#38551E",
	light_green = "#DFF0D0",
	dark_red = "#A50303",
	light_red = "#F7D9D9",
	dark_yellow = "#7E6901",
	light_yellow = "#FEF0B4",
	dark_cyan = "#37766F",
}

local p = {
	fg = colors.black,
	fg_muted = lighten(colors.black, 14),
	fg_dim = lighten(colors.white, -12),
	bg = lighten(colors.white, 3),
	menu_fg = colors.black,
	menu_bg = lighten(colors.white, -2),
	statusline_fg = lighten(colors.black, -7),
	statusline_bg = lighten(colors.white, -7),
	success_bg = colors.light_green,
	success_fg = colors.dark_green,
	warning_bg = colors.light_yellow,
	warning_fg = colors.dark_yellow,
	error_bg = colors.light_red,
	error_fg = colors.dark_red,
	info_bg = colors.light_blue,
	info_fg = colors.dark_blue,
	focus_fg = lighten(colors.accent, -50),
	focus_bg = lighten(colors.accent, 0),
}

local term_colors = TerminalColors {
	p.fg,
	p.error_fg,
	p.success_fg,
	p.warning_fg,
	p.info_fg,
	p.focus_fg,
	colors.dark_cyan,
	p.bg,
	p.fg,
	p.error_fg,
	p.success_fg,
	p.warning_fg,
	p.info_fg,
	p.focus_fg,
	colors.dark_cyan,
	p.bg,
}

-- empty colors to force lookups to use the __index metamethod, which can
-- then exit and warn you that you should from now on use the "palette" colors.
colors = {}
setmetatable(colors, {
	__index = function()
		print("get colors from palette instead")
		os.exit(1)
	end,
})

local theme_colors = {
	[[" Terminal Colors ]],
	term_colors,

	[[" UI & Syntax]],
	HLGroup { name = "Normal", guifg = p.fg, guibg = p.bg },
	HLGroup { name = "NormalNC", link = "Normal" },
	HLGroup {
		name = "StatusLine",
		guifg = p.statusline_fg,
		guibg = p.statusline_bg,
		gui = "NONE",
	},
	HLGroup {
		name = "StatusLineNC",
		guifg = lighten(p.statusline_fg, 7),
		guibg = lighten(p.statusline_bg, 7),
		gui = "NONE",
	},
	HLGroup { name = "MsgArea", link = "Normal" },
	HLGroup { name = "ColorColumn", guifg = "fg", guibg = lighten(p.bg, -4) },
	HLGroup { name = "Conceal", guifg = "fg", guibg = "NONE", gui = "underline" },
	HLGroup { name = "ToolbarButton", link = "TabLine" },
	HLGroup { name = "ToolbarLine", link = "TabLineFill" },
	HLGroup { name = "CursorColumn", guifg = "NONE", guibg = p.menu_bg },
	HLGroup { name = "Cursor", guifg = "bg", guibg = "fg" },
	HLGroup { name = "lCursor", link = "Cursor" },
	HLGroup { name = "CursorIM", link = "Cursor" },
	HLGroup { name = "CursorLine", guifg = "NONE", guibg = p.menu_bg, gui = "NONE" },
	HLGroup { name = "CursorLineNr", guifg = "NONE", guibg = p.menu_bg, gui = "NONE" },
	HLGroup { name = "CopilotSuggestion", guifg = p.fg_muted, guibg = "NONE" },
	HLGroup { name = "DiffAdd", guifg = p.success_fg, guibg = p.success_bg },
	HLGroup { name = "DiffChange", guifg = p.warning_fg, guibg = p.warning_bg },
	HLGroup { name = "DiffDelete", guifg = p.error_fg, guibg = p.error_bg, gui = "NONE" },
	HLGroup { name = "DiffText", guifg = p.info_fg, guibg = p.info_bg },
	HLGroup { name = "Directory", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "ErrorMsg", guifg = p.error_fg, guibg = "NONE", gui = "bold" },
	HLGroup { name = "Identifier", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Ignore", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "MatchParen", link = "CurSearch" },
	HLGroup {
		name = "WinBar",
		guifg = "fg",
		guibg = "NONE",
		gui = { "underline" },
		guisp = p.fg_muted,
	},
	HLGroup {
		name = "WinBarNC",
		guifg = p.fg_muted,
		guibg = "NONE",
		gui = "underline",
		guisp = p.fg_dim,
	},
	HLGroup {
		name = "TabLineSel",
		guifg = p.statusline_fg,
		guibg = p.statusline_bg,
		gui = { "NONE" },
	},
	HLGroup {
		name = "TabLine",
		guifg = p.statusline_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	HLGroup {
		name = "TabLineFill",
		guifg = p.statusline_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	HLGroup { name = "ModeMsg", guifg = p.info_fg, guibg = p.info_bg, gui = "NONE" },
	HLGroup { name = "MoreMsg", guifg = p.info_fg, guibg = p.info_bg, gui = "NONE" },
	HLGroup { name = "WarningMsg", guifg = p.warning_fg, guibg = p.warning_bg, gui = "NONE" },
	HLGroup { name = "NonText", guifg = p.fg_dim, guibg = "NONE" },
	HLGroup { name = "Whitespace", guifg = p.fg_dim, guibg = "NONE" },
	HLGroup { name = "Pmenu", guifg = p.menu_fg, guibg = p.menu_bg },
	HLGroup { name = "PmenuSel", guifg = p.focus_fg, guibg = p.focus_bg, gui = "bold" },
	HLGroup { name = "PmenuKind", guifg = p.menu_fg, guibg = p.menu_bg, gui = "italic" },
	HLGroup { name = "PmenuKindSel", guifg = p.focus_fg, guibg = p.focus_bg, gui = "italic" },
	HLGroup { name = "PmenuExtra", guifg = p.menu_fg, guibg = p.menu_bg },
	HLGroup { name = "PmenuExtraSel", guifg = p.focus_fg, guibg = p.focus_bg },
	HLGroup { name = "PmenuSbar", guifg = "NONE", guibg = p.menu_bg },
	HLGroup { name = "PmenuThumb", guifg = "NONE", guibg = lighten(p.menu_bg, -10) },
	HLGroup { name = "PreProc", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Question", guifg = "fg", guibg = "NONE" },
	HLGroup {
		name = "CurSearch",
		guifg = lighten(p.focus_fg, -8),
		guibg = lighten(p.focus_bg, -8),
		gui = "bold",
	},
	HLGroup { name = "IncSearch", guifg = p.focus_bg, guibg = p.focus_fg, gui = "NONE" },
	HLGroup {
		name = "Search",
		guifg = lighten(p.focus_fg, 0),
		guibg = lighten(p.focus_bg, 0),
		gui = "NONE",
	},
	HLGroup { name = "Visual", guifg = p.focus_fg, guibg = p.focus_bg },
	HLGroup {
		name = "VisualNOS",
		guifg = lighten(p.focus_fg, 5),
		guibg = lighten(p.focus_bg, 5),
	},
	HLGroup { name = "Special", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "SpecialKey", guifg = p.warning_fg, guibg = p.warning_bg },
	HLGroup { name = "SpellBad", guifg = "fg", guibg = "NONE", gui = "undercurl" },
	HLGroup { name = "SpellCap", link = "SpellBad" },
	HLGroup { name = "SpellLocal", link = "SpellBad" },
	HLGroup { name = "SpellRare", link = "SpellBad" },
	HLGroup { name = "Statement", guifg = "fg", guibg = "NONE", gui = "italic" },
	HLGroup { name = "Type", guifg = "NONE", guibg = "NONE", gui = "italic" },
	HLGroup { name = "Underlined", guifg = "fg", guibg = "NONE", gui = "underline" },
	HLGroup { name = "VertSplit", guifg = p.fg_dim, guibg = "NONE", gui = "NONE" },
	HLGroup { name = "Tooltip", guifg = p.menu_fg, guibg = p.menu_bg },
	HLGroup { name = "Menu", guifg = p.menu_fg, guibg = p.menu_bg },
	HLGroup { name = "Scrollbar", guifg = "NONE", guibg = p.menu_bg },
	HLGroup { name = "Title", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "MsgSeparator", link = "VertSplit" },
	HLGroup { name = "EndOfBuffer", link = "NonText" },
	HLGroup { name = "QuickFixLine", link = "Search" },
	Cond {
		"!has('nvim')",
		string.format(
			"%s\n%s",
			HLGroup { name = "StatusLineTerm", link = "StatusLine" },
			HLGroup { name = "StatusLineTermNC", link = "StatusLineNC" }
		),
	},
	HLGroup { name = "WildMenu", link = "IncSearch" },
	HLGroup { name = "Boolean", link = "Constant" },
	HLGroup { name = "Character", link = "Constant" },
	HLGroup { name = "Conditional", link = "Statement" },
	HLGroup { name = "Define", link = "PreProc" },
	HLGroup { name = "Debug", link = "Special" },
	HLGroup { name = "Delimiter", link = "Special" },
	HLGroup { name = "Float", link = "Number" },
	HLGroup { name = "Function", link = "Identifier" },
	HLGroup { name = "Include", link = "PreProc" },
	HLGroup { name = "Macro", link = "PreProc" },
	HLGroup { name = "Number", link = "Constant" },
	HLGroup { name = "PreCondit", link = "PreProc" },
	HLGroup { name = "SpecialChar", link = "Special" },
	HLGroup { name = "SpecialComment", link = "Special" },
	HLGroup { name = "StorageClass", link = "Type" },
	HLGroup { name = "String", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "Structure", link = "Type" },
	HLGroup { name = "Tag", link = "Special" },
	HLGroup { name = "Typedef", link = "Type" },
	HLGroup { name = "Substitute", link = "IncSearch" },
	HLGroup { name = "Operator", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Repeat", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Constant", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "jsParensError", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Todo", guifg = p.warning_fg, guibg = p.warning_bg, gui = "bold" },
	HLGroup { name = "Error", guifg = p.error_fg, guibg = "bg", gui = "bold" },
	HLGroup { name = "Exception", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Keyword", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "Label", guifg = "fg", guibg = "NONE" },
	[[" Floating Windows]],
	HLGroup { name = "NormalFloat", guifg = "fg", guibg = "bg" },
	HLGroup {
		name = "FloatTitle",
		guifg = "fg",
		guibg = "bg",
		gui = { "underline", "bold" },
	},
	HLGroup { name = "FloatBorder", guifg = "fg", guibg = "NONE" },
	"",

	[[" Diagnostic]],
	HLGroup { name = "DiagnosticError", guifg = p.error_fg, guibg = p.error_bg },
	HLGroup { name = "DiagnosticHint", guifg = p.success_fg, guibg = p.success_bg },
	HLGroup { name = "DiagnosticInfo", guifg = p.info_fg, guibg = p.info_bg },
	HLGroup { name = "DiagnosticWarn", guifg = p.warning_fg, guibg = p.warning_bg },
	HLGroup {
		name = "DiagnosticFloatingError",
		guifg = p.error_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	HLGroup { name = "DiagnosticFloatingHint", guifg = "NONE", guibg = "NONE", gui = "NONE" },
	HLGroup { name = "DiagnosticFloatingInfo", guifg = "NONE", guibg = "NONE", gui = "NONE" },
	HLGroup { name = "DiagnosticFloatingWarn", guifg = "NONE", guibg = "NONE", gui = "NONE" },
	HLGroup {
		name = "DiagnosticUnderlineError",
		guifg = "NONE",
		guibg = "NONE",
		gui = "undercurl",
		guisp = p.error_fg,
	},
	HLGroup {
		name = "DiagnosticUnderlineHint",
		guifg = "NONE",
		guibg = "NONE",
		gui = "undercurl",
		guisp = p.success_fg,
	},
	HLGroup {
		name = "DiagnosticUnderlineInfo",
		guifg = "NONE",
		guibg = "NONE",
		gui = "undercurl",
		guisp = p.info_fg,
	},
	HLGroup {
		name = "DiagnosticUnderlineWarn",
		guifg = "NONE",
		guibg = "NONE",
		gui = "undercurl",
		guisp = p.warning_fg,
	},
	HLGroup {
		name = "DiagnosticSignError",
		guifg = p.error_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	HLGroup {
		name = "DiagnosticSignHint",
		guifg = p.succes_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	HLGroup {
		name = "DiagnosticSignInfo",
		guifg = p.info_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	HLGroup {
		name = "DiagnosticSignWarn",
		guifg = p.warning_fg,
		guibg = "NONE",
		gui = "NONE",
	},
	"",

	[[" LSP]],
	HLGroup { name = "LspSignatureActiveParameter", link = "Search" },
	"",

	[[" Vim Script]],
	HLGroup { name = "vimCommand", guifg = "fg", guibg = "NONE", gui = "NONE" },
	HLGroup { name = "vimFilter", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "vimGroup", link = "Normal" },
	HLGroup { name = "vimHiGui", link = "Normal" },
	HLGroup { name = "vimHiKeyList", link = "Normal" },
	HLGroup { name = "vimHiGroup", link = "Normal" },
	HLGroup { name = "vimHiCTerm", link = "Normal" },
	HLGroup { name = "vimHiCTermFgBg", link = "Normal" },
	HLGroup { name = "vimHiGuiFgBg", link = "Normal" },
	"",

	[[" HTML]],
	HLGroup { name = "htmlTagName", guifg = "fg", guibg = "NONE", gui = "NONE" },

	[[" Lua]],
	HLGroup { name = "luaFuncKeyword", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "luaRepeat", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "luaParens", link = "Normal" },
	HLGroup { name = "luaSpecialValue", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "luaLocal", link = "Normal" },
	HLGroup { name = "luaBraces", link = "Normal" },
	HLGroup { name = "luaStatement", link = "Normal" },
	HLGroup { name = "luaBuiltIn", guifg = "fg", guibg = "NONE", gui = "underline" },

	[[" Typescript]],
	HLGroup { name = "typescriptParens", guifg = "fg", guibg = "NONE" },
	"",

	[[" Markdown]],
	HLGroup { name = "mkHeading", guifg = "NONE", guibg = "NONE", gui = "underline" },
	HLGroup { name = "mkItalic", guifg = "NONE", guibg = "NONE", gui = "italic" },
	HLGroup { name = "markdownBold", guifg = "NONE", guibg = "NONE", gui = "bold" },
	HLGroup { name = "markdownUrl", guifg = "NONE", guibg = "NONE", gui = "underline" },
	HLGroup { name = "markdownUrl", guifg = "NONE", guibg = "NONE", gui = "underline" },
	HLGroup {
		name = "markdownHeadingDelimiter",
		guifg = "NONE",
		guibg = "NONE",
		gui = "underline",
	},
	HLGroup { name = "mkCode", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "mkdCodeDelimiter", link = "mkCode" },
	HLGroup { name = "markdownItalic", link = "mkItalic" },
	HLGroup { name = "markdownLinkText", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "markdownH1", link = "mkdHeading" },
	HLGroup { name = "markdownH1Delimiter", link = "markdownHeadingDelimiter" },
	HLGroup { name = "markdownH2", link = "mkdHeading" },
	HLGroup { name = "markdownH3", link = "mkdHeading" },
	HLGroup { name = "markdownH4", link = "mkdHeading" },
	HLGroup { name = "markdownCodeDelimiter", guifg = "NONE", guibg = "NONE" },
	HLGroup { name = "markdownBoldDelimiter", guifg = "NONE", guibg = "NONE" },
	HLGroup { name = "markdownItalicDelimiter", guifg = "NONE", guibg = "NONE" },
	HLGroup { name = "markdownBoldItalicDelimiter", guifg = "NONE", guibg = "NONE" },
	HLGroup { name = "markdownLinkDelimiter", guifg = "NONE", guibg = "NONE" },
	HLGroup { name = "markdownLinkTextDelimiter", guifg = "NONE", guibg = "NONE" },
	"",

	[["  Help Text]],
	HLGroup { name = "helpBacktick", link = "Constant" },
	HLGroup { name = "helpCommand", link = "Constant" },
	HLGroup { name = "helpDeprecated", link = "DiffDelete" },
	HLGroup { name = "helpExample", guifg = "fg", guibg = "bg", gui = "bold" },
	HLGroup { name = "helpHeader", guifg = "NONE", guibg = "NONE", gui = "bold" },
	HLGroup { name = "helpHeadline", guifg = "fg", guibg = "NONE", gui = { "bold" } },
	HLGroup {
		name = "helpHyperTextEntry",
		guifg = "NONE",
		guibg = "NONE",
		gui = "underline",
	},
	HLGroup { name = "helpHyperTextJump", guifg = "NONE", guibg = "NONE", gui = "underline" },
	HLGroup { name = "helpNote", guifg = "NONE", guibg = "NONE", gui = "bold" },
	HLGroup { name = "helpOption", guifg = "NONE", guibg = "NONE", gui = "bold" },
	HLGroup { name = "helpSectionDelim", guifg = p.fg_dim, guibg = "NONE", gui = "NONE" },
	HLGroup { name = "helpSpecial", guifg = "NONE", guibg = "NONE", gui = "bold" },
	HLGroup { name = "helpURL", guifg = "NONE", guibg = "NONE", gui = "underline" },
	"",

	Cond {
		"has('nvim')",
		string.format(
			'" Help Text TS\n%s\n%s',
			HLGroup { name = "@text.literal", link = "helpExample" },
			HLGroup { name = "@text.reference", link = "helpOption" }
		),
	},
	"",

	[[" XML]],
	HLGroup { name = "xmlProcessingDelim", link = "Normal" },
	HLGroup { name = "xmlTagName", guifg = "NONE", guibg = "NONE", gui = "NONE" },
	"",

	[[" fugitive]],
	HLGroup {
		name = "fugitiveStagedSection",
		guifg = "fg",
		guibg = "NONE",
		gui = { "underline", "bold" },
	},
	HLGroup {
		name = "fugitiveUnstagedSection",
		guifg = "fg",
		guibg = "NONE",
		gui = { "underline", "bold" },
	},
	HLGroup { name = "diffAdded", link = "DiffAdd" },
	HLGroup { name = "diffLine", guifg = "fg", guibg = "NONE", gui = "bold" },
	HLGroup { name = "gitHashAbbrev", guifg = "fg", guibg = "NONE", gui = "underline" },
	HLGroup { name = "diffChanged", link = "DiffChange" },
	HLGroup { name = "diffRemoved", link = "DiffDelete" },
	HLGroup { name = "diffComment", link = "Comment" },
	HLGroup { name = "diffSubname", guifg = "fg", guibg = "NONE", gui = "bold" },
	"",

	[[" Git Signs]],
	HLGroup { name = "GitSignsAdd", link = "DiffAdd" },
	HLGroup { name = "GitSignsAddNr", link = "DiffAdd" },
	HLGroup { name = "GitSignsAddLn", link = "DiffAdd" },
	HLGroup { name = "GitSignsChange", link = "DiffChange" },
	HLGroup { name = "GitSignsChangeNr", link = "DiffChange" },
	HLGroup { name = "GitSignsChangeLn", link = "DiffChange" },
	HLGroup { name = "GitSignsDelete", link = "DiffDelete" },
	HLGroup { name = "GitSignsDeleteNr", link = "DiffDelete" },
	HLGroup { name = "GitSignsDeleteLn", link = "DiffDelete" },
	"",

	[[" Indent Blank Line]],
	HLGroup { name = "IndentBlanklineChar", link = "VertSplit" },
	"",

	[[" Sneak]],
	HLGroup { name = "Sneak", link = "Visual" },
	HLGroup { name = "SneakScope", link = "IncSearch" },
	HLGroup { name = "SneakLabel", link = "Search" },
	"",

	[[" Dirvish]],
	HLGroup { name = "DirvishPathTail", guifg = "NONE", guibg = "NONE", gui = "bold" },
	HLGroup { name = "DirvishArg", link = "Search" },
	"",

	[[" HL Search Lens]],
	HLGroup { name = "HlSearchLensNear", link = "StatusLine" },
	HLGroup { name = "HlSearchLens", link = "StatusLineNC" },
	HLGroup { name = "HlSearchNear", link = "Search" },
	"",

	[[" Conflict Marker]],
	HLGroup { name = "ConflictMarkerBegin", link = "DiffAdd" },
	HLGroup { name = "ConflictMarkerOurs", link = "DiffAdd" },
	HLGroup { name = "ConflictMarkerTheirs", link = "DiffText" },
	HLGroup { name = "ConflictMarkerEnd", link = "DiffText" },
	"",

	[[" Treesitter Context]],
	HLGroup { name = "TreesitterContextBottom", gui = "underline" },
	HLGroup { name = "TreesitterContext", guifg = "fg", guibg = p.menu_bg, gui = "bold" },
	"",

	[[" Leap]],
	HLGroup { name = "LeapMatch", guifg = p.success_fg, guibg = p.success_bg, gui = "NONE" },
	HLGroup {
		name = "LeapLabelPrimary",
		guifg = p.info_fg,
		guibg = p.info_bg,
		gui = "bold",
	},
	HLGroup {
		name = "LeapLabelSecondary",
		guifg = lighten(p.info_fg, 6),
		guibg = lighten(p.info_bg, 6),
		gui = "NONE",
	},
	HLGroup {
		name = "LeapLabelSelected",
		guifg = p.focus_fg,
		guibg = p.focus_bg,
		gui = "NONE",
	},
	"",

	[[" Which Key]],
	HLGroup { name = "WhichKeySeperator", guifg = "fg", guibg = "NONE" },
	HLGroup { name = "WhichKeyFloating", link = "Pmenu" },
	"",

	[[" Telescope]],
	HLGroup {
		name = "TelescopeMatching",
		link = "CurSearch",
	},
	HLGroup {
		name = "TelescopeSelection",
		link = "Search",
	},
	"",

	ThemeOption {
		name = "yui_folds",
		description = "How folds should be displayed",
		default = "'fade'",
		cases = {
			["'emphasize'"] = {
				description = "Make folds more visible",
				groups = {
					HLGroup { name = "FoldColumn", guifg = p.menu_fg, guibg = p.menu_bg },
					HLGroup { name = "Folded", guifg = p.menu_fg, guibg = p.menu_bg },
				},
			},
			["'fade'"] = {
				description = "Fade out folds",
				groups = {
					HLGroup { name = "FoldColumn", guifg = p.fg_dim, guibg = "NONE" },
					HLGroup { name = "Folded", guifg = p.fg_dim, guibg = "NONE" },
				},
			},
		},
	},
	ThemeOption {
		name = "yui_line_numbers",
		default = "'fade'",
		description = "How line numbers should be displayed",
		cases = {
			["'emphasize'"] = {
				description = "Make line numbers more visible",
				groups = {
					HLGroup { name = "SignColumn", guifg = p.menu_fg, guibg = p.menu_bg },
					HLGroup { name = "LineNr", guifg = p.menu_fg, guibg = p.menu_bg },
				},
			},
			["'fade'"] = {
				description = "Fade out line numbers",
				groups = {
					HLGroup { name = "SignColumn", guifg = p.fg_dim, guibg = "NONE" },
					HLGroup { name = "LineNr", guifg = p.fg_dim, guibg = "NONE" },
				},
			},
		},
	},
	-- This has to come before yui_comments, so that yui_comments can override it.
	ThemeOption {
		name = "yui_emphasized_comments",
		default = 0,
		deprecated = "Use |yui_comments| instead",
		description = "Whether to emphasize comments",
		cases = {
			[1] = {
				description = "Emphasize comments",
				groups = {
					HLGroup {
						name = "Comment",
						guifg = p.focus_fg,
						guibg = "NONE",
						gui = "italic",
					},
				},
			},
			[0] = {
				description = "Do not emphasize comments",
				groups = {
					HLGroup { name = "Comment", guifg = p.fg_dim, guibg = "NONE", gui = "italic" },
				},
			},
		},
	},
	ThemeOption {
		name = "yui_comments",
		default = "'normal'",
		description = "How comments should be displayed",
		cases = {
			["'emphasize'"] = {
				description = "Emphasize comments",
				groups = {
					HLGroup {
						name = "Comment",
						guifg = p.focus_fg,
						guibg = "NONE",
						gui = "italic",
					},
				},
			},
			["'fade'"] = {
				description = "Fade out comments",
				groups = {
					HLGroup { name = "Comment", guifg = p.fg_dim, guibg = "NONE", gui = "italic" },
				},
			},
			["'normal'"] = {
				description = "Do not emphasize comments",
				groups = {
					HLGroup { name = "Comment", guifg = "fg", guibg = "NONE", gui = "italic" },
				},
			},
			["'bg'"] = {
				description = "Make comments have a background color",
				groups = {
					HLGroup { name = "Comment", guifg = p.menu_fg, guibg = p.menu_bg, gui = "NONE" },
				},
			},
		},
	},
	ThemeOption {
		name = "yui_lightline",
		default = "v:false",
		deprecated = [[
The lightline initialization is now done through
an autoloaded function. You therefore no longer
need to tell the yui theme whether or not you're
using lightline]],
		example = [[
  let g:yui_lightline = v:true
  let g:lightline.colorscheme = 'yui']],
		description = "Whether to use the lightline theme",
		cases = {},
	},
}

local theme = Theme {
	name = "yui",
	palette = p,
	colors = theme_colors,
}

local lightline = Lightline(p)

return {
	theme = theme,
	lightline = lightline,
}
