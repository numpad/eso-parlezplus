
Response = {
	person = "",
	text = "",
	color = Defines.TextColor.NPCText,
	is_duplicate = false,
	from_player = false
}

function Response:new(r)
	r = r or {}
	setmetatable(r, self)
	self.__index = self
	return r
end

function Response:format()
	return ColoredText(
		self:getName()
		.. self.text, self.color[1], self.color[2], self.color[3]) .. "\n"
end

function Response:getOwnLine()
	if self.from_player and Defines.Flags.PlayerNameOwnLine then
		return "\n"
	elseif self.from_player == false and Defines.Flags.NPCNameOwnLine then
		return "\n"
	end

	return ""
end

function Response:getName()

	local display_name = nil
	if self.from_player then
		display_name = Defines.Flags.DisplayPlayerName
	else
		display_name = Defines.Flags.DisplayNPCName
	end

	if not display_name then
		return ""
	end

	return UnderlinedText(
		self.person .. ":",
		self.color[1], self.color[2], self.color[3])
		.. " " .. self:getOwnLine()
end
