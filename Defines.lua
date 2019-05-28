
-- call function f after ms milliseconds.
function setTimeout(f, ms)
	zo_callLater(f, ms)
end

-- Color as red, green, blue in range [0, 256)
local function Color(r, g, b)
	return {r, g, b}
end

-- Colors used for different text types.
TextColor = {
	PlayerResponse = Color(255, 200, 100), -- Color of the player's response to the NPCs text.
	PlayerDuplicateResponse = Color(110, 90, 70), -- Color if the player has already given this response.
	NPCText = Color(245, 245, 245), -- Color of the NPCs text.
	NPCDuplicateText = Color(187, 187, 187) -- Color if the NPC answered a duplicate question.
}

Timeout = {
	-- Delay until NPC dialog appears after the player responded.
	NPCAfterResponse = 700
}

function LoadSavedDefines(savedVars)
	savedVars.NPCAfterResponse = savedVars.NPCAfterResponse or Timeout.NPCAfterResponse

	Timeout.NPCAfterResponse = savedVars.NPCAfterResponse

end
