local net = require("@lune/net")
local serde = require("@lune/serde")

type Impl = {
	__index: Impl,
	new: () -> Response,

	status: (self: Response, code: number) -> Response,
	json: (self: Response, value: any) -> Response,
	respond: (self: Response) -> net.ServeResponse,
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

	return self
end

function Response:status(code: number)
	self.code = code
	return self
end

function Response:json(value: any)
	self.body = serde.encode("json", value, true)
	return self
end

function Response:respond()
	return {
		body = self.body,
		headers = self.headers,
		status = self.code,
	} :: net.ServeResponse
end

return Response
