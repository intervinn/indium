local net = require("@lune/net")
local serde = require("@lune/serde")

type Impl = {
	__index: Impl,
	new: () -> Response,

	status: (self: Response, code: number) -> Response,
	json: (self: Response, value: any) -> Response,
	text: (self: Response, value: string) -> Response,
	respond: (self: Response) -> net.ServeResponse,
	set: (self: Response, key: string, value: string) -> (),
	
	html: (self: Response, content: string) -> Response,
	redirect: (self: Response, to: string) -> Response,
}

type Proto = {
	body: string,
	headers: { [string]: string },
	code: number,
}

local Response: Impl = {} :: Impl
Response.__index = Response

export type Response = typeof(setmetatable({} :: Proto, {} :: Impl))

function Response.new()
	local self = setmetatable({} :: Proto, Response)
	self.headers = {}
	self.code = -1
	self.body = nil :: any

	return self
end

function Response:set(key, value)
	self.headers[key] = value
end

function Response:status(code)
	self.code = code
	return self
end

function Response:json(value)
	self.headers["Content-Type"] = "application/json"
	self.body = serde.encode("json", value, true)
	return self
end

function Response:text(value)
	self.headers["Content-Type"] = "text/plain"
	self.body = value
	return self
end

function Response:html(content: string)
	self:set("Content-Type", "text/html; charset=utf-8")
	self.body = content
	return self
end

function Response:redirect(to)
	self:set("Location", to)
	if not self.status then self:status(302) end
	return self
end

function Response:respond()
	return {
		body = self.body,
		headers = self.headers,
		status = self.code,
	}
end

return Response
