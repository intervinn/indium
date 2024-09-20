local std = require("@util/std")

type Impl = {
	__index: Impl,
	new: (params: Proto) -> Request,
	get: (self: Request, key: string) -> string?,
	match: (self: Request, template: string) -> (),
}

type Proto = {
	params: {[string]: string},
	headers: {[string]: string},
	method: std.HttpMethod,
	path: string,
	query: {[string]: string?},
	body: string
}

local Request: Impl = {} :: Impl
Request.__index = Request

export type Request = typeof(setmetatable({} :: Proto, {} :: Impl))

function Request.new(params: Proto)
	local self = setmetatable(params :: Proto, Request)

	return self
end

function Request:match(template: string)
	local routePieces = {}
	local templatePieces = {}

	for str in self.path:gmatch("([^/]+)") do
		table.insert(routePieces, str)
	end

	for str in template:gmatch("([^/]+)") do
		table.insert(templatePieces, str)
	end

	for i = 1, #routePieces do
		if templatePieces[i]:sub(1,1) == ":" then
			self.params[templatePieces[i]:sub(2)] = routePieces[i]
		end
	end
end

function Request:get(key: string)
	return self.headers[key]
end

return Request
