
Response = {
	person = "",
	text = "",
	color = TextColor.NPCText,
	is_duplicate = false
}

function Response:new(r)
	r = r or {}
	setmetatable(r, self)
	self.__index = self
	return r
end

function Response:format()
	return ColoredText(
		UnderlinedText(self.person .. ":", self.color[1], self.color[2], self.color[3])
		.. " " .. self.text, self.color[1], self.color[2], self.color[3]) .. "\n"
end
