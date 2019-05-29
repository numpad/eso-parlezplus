
local LAM = LibStub("LibAddonMenu-2.0")

Defines = {}

-- call function f after ms milliseconds.
function setTimeout(f, ms)
	zo_callLater(f, ms)
end

-- Color as red, green, blue in range [0, 256)
local function Color(r, g, b)
	return {r, g, b}
end

local function FloatColor(r, g, b)
	return {Clamp(r * 255, 0, 255),
		Clamp(g * 255, 0, 255),
		Clamp(b * 255, 0, 255)}
end

local function UnpackColor(c)
	return c[1], c[2], c[3]
end

-- Colors used for different text types.
Defines.TextColor = {
	PlayerResponse = Color(255, 200, 100), -- Color of the player's response to the NPCs text.
	PlayerDuplicateResponse = Color(110, 90, 70), -- Color if the player has already given this response.
	NPCText = Color(245, 245, 245), -- Color of the NPCs text.
	NPCDuplicateText = Color(187, 187, 187) -- Color if the NPC answered a duplicate question.
}

Defines.Timeout = {
	-- Delay until NPC dialog appears after the player responded.
	NPCAfterResponse = 700
}

Defines.Flags = {
	DisplayNPCName = true,
	DisplayPlayerName = true,
	DisplayPlayerText = true,
	PlayerNameOwnLine = false,
	NPCNameOwnLine = false,
	NewlineAfterPlayerText = false,
	NewlineAfterNPCText = false,
	DisplayDialogTitle = false,
	DelayedNPCResponse = false
}

Defines.FormatString = {
	PlayerNameFormat = "{u}{{name}}:{/u} ",
	NPCNameFormat = "{u}{{name}}:{/u} "
}

function Defines.FormatDefault(str, data)
	local res = str
	-- underline
	res = string.gsub(res, "{u}", string.format("|l0:1:1:2:2:%.2X%.2X%.2X|l", UnpackColor(data.color)))
	res = string.gsub(res, "{/u}", "|l")

	return res
end

-- Formats a Defines.FormatString
function Defines.Format(str, data)
	-- default values
	data.name = data.name or "NO_NAME_GIVEN"
	data.color = data.color or Color(255, 0, 0)

	-- apply standard formats such as underline, etc.
	local res = Defines.FormatDefault(str, data)

	for key, value in pairs(data) do
		res = string.gsub(res, "{{" .. key .. "}}", value)
	end

	return res
end


function Defines:Initialize()
	self.savedVars = ZO_SavedVars:NewAccountWide("ParlezPlusSavedVariables", 1, nil, {})

	-- Save Variables that are not yet saved.
	self.savedVars.Timeout = self.savedVars.Timeout or self.Timeout
	self.savedVars.TextColor = self.savedVars.TextColor or self.TextColor
	self.savedVars.Flags = self.savedVars.Flags or self.Flags
	self.savedVars.FormatString = self.savedVars.FormatString or self.FormatString

	-- Load saved variables
	self.Timeout = self.savedVars.Timeout
	self.TextColor = self.savedVars.TextColor
	self.Flags = self.savedVars.Flags
	self.FormatString = self.savedVars.FormatString
	
	-- Configure AddonMenu
	local panelData = {
		type = "panel",
		name = "|ce24441Par|r|cFFFFFFlez|r|c418be0Plus|r",
		author = "@numpad0to9"
	}
	local optionsData = Defines:CreateOptionsData()

	-- Load AddonMenu
	LAM:RegisterAddonPanel("ParlezPlusOptions", panelData)
	LAM:RegisterOptionControls("ParlezPlusOptions", optionsData)
end

function Defines:CreateOptionsData()
	return {
		{
			type = "slider",
			name = "Response Delay",
			min = 0,
			max = 2000,
			step = 1,
			decimals = 2,
			tooltip = "Delay (in milliseconds) after answering an NPC until it's response dialog text is visible.",
			getFunc = function () return Defines.Timeout.NPCAfterResponse end,
			setFunc = function (v) Defines.Timeout.NPCAfterResponse = v end,
			clampInput = false
		},
		-- colors
		{
			type = "colorpicker",
			name = "Player Response",
			tooltip = "Color of the players response.",
			width = "half",
			getFunc = function ()
				return Defines.TextColor.PlayerResponse[1] / 255,
					Defines.TextColor.PlayerResponse[2] / 255,
					Defines.TextColor.PlayerResponse[3] / 255
			end,
			setFunc = function (r, g, b) Defines.TextColor.PlayerResponse = FloatColor(r, g, b) end
		},
		{
			type = "colorpicker",
			name = "NPC Text",
			tooltip = "Color of the NPCs dialog text.",
			width = "half",
			getFunc = function ()
				return Defines.TextColor.NPCText[1] / 255,
					Defines.TextColor.NPCText[2] / 255,
					Defines.TextColor.NPCText[3] / 255
			end,
			setFunc = function (r, g, b) Defines.TextColor.NPCText = FloatColor(r, g, b) end
		},{
			type = "colorpicker",
			name = "Player Response (duplicate)",
			tooltip = "Color of the players response if he already gave it before.",
			width = "half",
			getFunc = function ()
				return Defines.TextColor.PlayerDuplicateResponse[1] / 255,
					Defines.TextColor.PlayerDuplicateResponse[2] / 255,
					Defines.TextColor.PlayerDuplicateResponse[3] / 255
			end,
			setFunc = function (r, g, b) Defines.TextColor.PlayerDuplicateResponse = FloatColor(r, g, b) end
		},
		{
			type = "colorpicker",
			name = "NPC Text (duplicate)",
			tooltip = "Color of the NPCs dialog text if he already said it before.",
			width = "half",
			getFunc = function ()
				return Defines.TextColor.NPCDuplicateText[1] / 255,
					Defines.TextColor.NPCDuplicateText[2] / 255,
					Defines.TextColor.NPCDuplicateText[3] / 255
			end,
			setFunc = function (r, g, b) Defines.TextColor.NPCDuplicateText = FloatColor(r, g, b) end
		},
		-- flags
		{
			type = "checkbox",
			name = "Display Player name",
			tooltip = "Display the players name before its dialog text?\n"
				.. "Default: on",
			width = "half",
			getFunc = function () return Defines.Flags.DisplayPlayerName end,
			setFunc = function (v) Defines.Flags.DisplayPlayerName = v end
		},
		{
			type = "checkbox",
			name = "Display NPC name",
			tooltip = "Display the NPCs name before its dialog text?\n"
				.. "Default: on",
			width = "half",
			getFunc = function () return Defines.Flags.DisplayNPCName end,
			setFunc = function (v) Defines.Flags.DisplayNPCName = v end
		},
		{
			type = "checkbox",
			name = "Player name on own line",
			tooltip = "Display the player name on its own line, before the players response text.\n"
				.. "Default: off",
			width = "half",
			getFunc = function () return Defines.Flags.PlayerNameOwnLine end,
			setFunc = function (v) Defines.Flags.PlayerNameOwnLine = v end
		},
		{
			type = "checkbox",
			name = "NPC name on own line",
			tooltip = "Display the NPCs name on its own line, before the NPCs response text.\n"
				.. "Default: off",
			width = "half",
			getFunc = function () return Defines.Flags.NPCNameOwnLine end,
			setFunc = function (v) Defines.Flags.NPCNameOwnLine = v end
		},
		{
			type = "checkbox",
			name = "Newline after player text",
			tooltip = "Append a newline after the players response text.\n"
				.. "Default: off",
			width = "half",
			getFunc = function () return Defines.Flags.NewlineAfterPlayerText end,
			setFunc = function (v) Defines.Flags.NewlineAfterPlayerText = v end
		},
		{
			type = "checkbox",
			name = "Newline after NPC text",
			tooltip = "Append a newline after the NPCs dialog text.\n"
				.. "Default: off",
			width = "half",
			getFunc = function () return Defines.Flags.NewlineAfterNPCText end,
			setFunc = function (v) Defines.Flags.NewlineAfterNPCText = v end
		},
		{
			type = "checkbox",
			name = "Display players responses",
			tooltip = "Show the players response?\n"
				.. "Default: on",
			getFunc = function () return Defines.Flags.DisplayPlayerText end,
			setFunc = function (v) Defines.Flags.DisplayPlayerText = v end
		},
		{
			type = "checkbox",
			name = "Show dialog title",
			tooltip = "Display the dialog title?\n"
				.. "Default: off",
			getFunc = function () return Defines.Flags.DisplayDialogTitle end,
			setFunc = function (v) Defines.Flags.DisplayDialogTitle = v end
		},
		{
			type = "checkbox",
			name = "Delayed NPC Response",
			tooltip = "Delay closing the dialog window after giving a final response. WARNING: Experimental feature!\n"
				.. "Default: off",
			getFunc = function () return Defines.Flags.DelayedNPCResponse end,
			setFunc = function (v) Defines.Flags.DelayedNPCResponse = v end
		},
		{
			type = "editbox",
			name = "Player name format string",
			tooltip = "How the players name should be formatted in the conversation.\n"
				.. "Default: '{u}{{name}}:{/u} '"
				.. "Format Tags: {u}UNDERLINE{/u}, {{name}}",
			isMultiline = false,
			getFunc = function () return Defines.FormatString.PlayerNameFormat end,
			setFunc = function (v) Defines.FormatString.PlayerNameFormat = v end
		},
		{
			type = "editbox",
			name = "NPC name format string",
			tooltip = "How the NPCs name should be formatted in the conversation.\n"
				.. "Default: '{u}{{name}}:{/u} '"
				.. "Format Tags: {u}UNDERLINE{/u}, {{name}}",
			isMultiline = false,
			getFunc = function () return Defines.FormatString.NPCNameFormat end,
			setFunc = function (v) Defines.FormatString.NPCNameFormat = v end
		}
	}
end
