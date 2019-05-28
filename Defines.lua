
-- Color as red, green, blue in range [0, 256)
local function Color(r, g, b)
	return {r, g, b}
end

TextColor = {
	PlayerResponse = Color(255, 200, 100), -- Color of the player's response to the NPCs text.
	PlayerDuplicateResponse = Color(110, 90, 70), -- Color if the player has already given this response.
	NPCText = Color(245, 245, 245) -- Color of the NPCs text.
}

