local std = require("@util/std")
local serde = require("@lune/serde")

type Impl = {
	__index: Impl,
	new: () -> Response,

	status: (self: Response, code: number) -> Response,
	json: (self: Response, value: any) -> Response,
	text: (self: Response, value: string) -> Response,
	respond: (self: Response) -> std.ServeResponse,
	set: (self: Response, key: string, value: string) -> (),
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

function Response:set(key: string, value: string)
	self.headers[key] = value
end

function Response:status(code: number)
	self.code = code
	return self
end

function Response:json(value: any)
	self.headers["Content-Type"] = "application/json"
	self.body = serde.encode("json", value, true)
	return self
end

function Response:text(value: string)
	self.headers["Content-Type"] = "text/plain"
	self.body = value
	return self
end

function Response:respond()
	return {
		body = self.body,
		headers = self.headers,
		status = self.code,
	} :: std.ServeResponse
end

return Response
