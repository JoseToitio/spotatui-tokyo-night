-- Self-check for main.lua. Stubs the host API, then exercises startup and cycling.
--
--   lua test.lua      (or luajit test.lua)

local store, notices = {}, {}
local handlers, commands = {}, {}

-- The most recent set_theme table: spotatui theme field -> color string.
---@type table<string, string>
local applied = {}

-- Every field main.lua is expected to set, so a dropped line fails loudly
-- instead of leaving that field on the previous variant's color.
local REQUIRED_FIELDS = {
	"background",
	"text",
	"active",
	"hovered",
	"selected",
	"header",
	"banner",
	"playbar_background",
	"playbar_progress",
	"playbar_text",
	"playbar_progress_text",
	"highlighted_lyrics",
	"analysis_bar",
	"analysis_bar_text",
	"error_text",
	"error_border",
	"hint",
	"inactive",
}

-- The field names spotatui actually accepts, from docs/scripting.md "Theme
-- overrides". set_theme raises on anything else, so reject it here too.
local VALID_FIELDS = {}
for _, name in ipairs({
	"active",
	"banner",
	"error_border",
	"error_text",
	"hint",
	"hovered",
	"inactive",
	"playbar_background",
	"playbar_progress",
	"playbar_progress_text",
	"playbar_text",
	"selected",
	"text",
	"background",
	"header",
	"highlighted_lyrics",
	"analysis_bar",
	"analysis_bar_text",
}) do
	VALID_FIELDS[name] = true
end

-- Deliberately a global, not a local: spotatui injects this table as a global,
-- and the loadfile'd main.lua below resolves it through _ENV. A local here
-- would be invisible to that chunk.
_G.spotatui = {
	require_api = function(n)
		assert(n == 5, "expected require_api(5), got " .. tostring(n))
	end,
	set_theme = function(tbl)
		for field, color in pairs(tbl) do
			assert(VALID_FIELDS[field], "set_theme would raise on unknown field: " .. field)
			-- Same shape spotatui parses: three 0-255 components.
			local r, g, b = color:match("^(%d+), (%d+), (%d+)$")
			assert(r, "bad color string for " .. field .. ": " .. tostring(color))
			for _, component in ipairs({ r, g, b }) do
				assert(tonumber(component) <= 255, "component out of range for " .. field)
			end
		end
		applied = tbl
	end,
	storage_get = function(key)
		return store[key]
	end,
	storage_set = function(key, value)
		store[key] = value
	end,
	-- Keeps the real two-argument shape so main.lua's ttl argument is not
	-- reported as redundant against this stub.
	notify = function(msg, ttl_secs)
		notices[#notices + 1] = { msg = msg, ttl_secs = ttl_secs }
	end,
	on = function(event, fn)
		handlers[event] = fn
	end,
	register_command = function(name, fn)
		assert(not commands[name], "duplicate command: " .. name)
		commands[name] = fn
	end,
}

assert(loadfile("main.lua"))()

local function check_complete(label)
	for _, field in ipairs(REQUIRED_FIELDS) do
		assert(applied[field], label .. " did not set " .. field)
	end
	local count = 0
	for _ in pairs(applied) do
		count = count + 1
	end
	assert(count == #REQUIRED_FIELDS, label .. " set " .. count .. " fields, expected " .. #REQUIRED_FIELDS)
end

-- Startup with an empty store falls back to the default variant.
handlers.start()
check_complete("start")
local night_bg = applied.background
assert(night_bg == "26, 27, 38", "default variant should be night, got bg " .. night_bg)

-- Cycling walks night -> storm -> moon -> night and persists each step.
local cycle = commands.tokyo_night_cycle
local expected = {
	{ variant = "storm", bg = "36, 40, 59" },
	{ variant = "moon", bg = "34, 36, 54" },
	{ variant = "night", bg = "26, 27, 38" },
}
for _, step in ipairs(expected) do
	cycle()
	check_complete(step.variant)
	assert(applied.background == step.bg, step.variant .. " bg was " .. applied.background)
	assert(store.variant == step.variant, "store holds " .. tostring(store.variant))
	local notice = notices[#notices]
	assert(notice.msg == "Tokyo Night: " .. step.variant, "bad notice: " .. notice.msg)
	assert(notice.ttl_secs == 2, "notice ttl was " .. tostring(notice.ttl_secs))
end

-- analysis_bar_text tracks the variant background, per the documented mapping.
assert(applied.analysis_bar_text == applied.background, "analysis_bar_text should equal bg")

-- A stale or hand-edited variant name must not error, it falls back to night.
store.variant = "daylight-saving"
handlers.start()
assert(applied.background == night_bg, "unknown stored variant should fall back to night")

-- A restart mid-cycle resumes on the stored variant rather than the default.
store.variant = "moon"
handlers.start()
assert(applied.background == "34, 36, 54", "start should honour the stored variant")

print("ok: " .. (#expected + 3) .. " variant applications checked")
