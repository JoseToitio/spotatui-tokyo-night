-- Tokyo Night for spotatui.
--
-- Applies the saved variant on startup and cycles through variants with the
-- `tokyo_night_cycle` command. The chosen variant persists across restarts,
-- which it has to: set_theme overrides are runtime-only and reset on restart.
--
-- Suggested binding, in ~/.config/spotatui/config.yml:
--   plugin_commands:
--     tokyo_night_cycle: "ctrl-t"

spotatui.require_api(5) -- storage_get/storage_set

-- Palettes are the upstream folke/tokyonight.nvim values, as "r, g, b".
-- Night is Storm with the background keys overridden, exactly as upstream does it.
local palettes = {
	night = {
		bg = "26, 27, 38", -- #1a1b26
		bg_highlight = "41, 46, 66", -- #292e42
		fg = "192, 202, 245", -- #c0caf5
		blue = "122, 162, 247", -- #7aa2f7
		cyan = "125, 207, 255", -- #7dcfff
		magenta = "187, 154, 247", -- #bb9af7
		green = "158, 206, 106", -- #9ece6a
		red = "247, 118, 142", -- #f7768e
		comment = "86, 95, 137", -- #565f89
	},
	storm = {
		bg = "36, 40, 59", -- #24283b
		bg_highlight = "41, 46, 66", -- #292e42
		fg = "192, 202, 245", -- #c0caf5
		blue = "122, 162, 247", -- #7aa2f7
		cyan = "125, 207, 255", -- #7dcfff
		magenta = "187, 154, 247", -- #bb9af7
		green = "158, 206, 106", -- #9ece6a
		red = "247, 118, 142", -- #f7768e
		comment = "86, 95, 137", -- #565f89
	},
	moon = {
		bg = "34, 36, 54", -- #222436
		bg_highlight = "47, 51, 77", -- #2f334d
		fg = "200, 211, 245", -- #c8d3f5
		blue = "130, 170, 255", -- #82aaff
		cyan = "134, 225, 252", -- #86e1fc
		magenta = "192, 153, 255", -- #c099ff
		green = "195, 232, 141", -- #c3e88d
		red = "255, 117, 127", -- #ff757f
		comment = "99, 109, 166", -- #636da6
	},
}

-- Cycle order, and the default when nothing is stored yet.
local variants = { "night", "storm", "moon" }

-- Guard against a palette missing a key, which would silently leave that
-- spotatui field on whatever the previous variant set.
for name, palette in pairs(palettes) do
	for _, key in ipairs({
		"bg",
		"bg_highlight",
		"fg",
		"blue",
		"cyan",
		"magenta",
		"green",
		"red",
		"comment",
	}) do
		assert(palette[key], "tokyo-night: palette '" .. name .. "' is missing '" .. key .. "'")
	end
end

-- One mapping from tokyonight palette keys to spotatui theme fields, shared by
-- every variant, so a new palette is the only thing a new variant needs.
--
-- `text` is deliberately pure white rather than the palette's `fg`: it is the
-- primary list/body foreground and the extra contrast against these dark
-- backgrounds reads better than #c0caf5 does. `playbar_text` still uses `fg`.
local function apply(name)
	local p = palettes[name]
	spotatui.set_theme({
		background = p.bg,
		text = "255, 255, 255",
		active = p.blue,
		hovered = p.blue,
		selected = p.cyan,
		header = p.magenta,
		banner = p.magenta,
		playbar_background = p.bg_highlight,
		playbar_progress = p.green,
		playbar_text = p.fg,
		playbar_progress_text = p.fg,
		highlighted_lyrics = p.cyan,
		analysis_bar = p.blue,
		analysis_bar_text = p.bg,
		error_text = p.red,
		error_border = p.red,
		hint = p.comment,
		inactive = p.comment,
	})
end

-- Read at call time, never at load time: the store is only meaningful once the
-- app is running. An unknown or removed variant falls back to the default.
local function current()
	local saved = spotatui.storage_get("variant")
	if type(saved) == "string" and palettes[saved] then
		return saved
	end
	return variants[1]
end

spotatui.on("start", function()
	apply(current())
end)

spotatui.register_command("tokyo_night_cycle", function()
	local cur = current()
	local index = 1
	for i, name in ipairs(variants) do
		if name == cur then
			index = i
			break
		end
	end

	local next_variant = variants[(index % #variants) + 1]
	spotatui.storage_set("variant", next_variant)
	apply(next_variant)
	spotatui.notify("Tokyo Night: " .. next_variant, 2)
end)
