local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: (request: net.ServeRequest) -> Request,
	get: (self: Request, key: string) -> string?,
}

type Proto = {} & net.ServeRequest

local Request: Impl = {} :: Impl
Request.__index = Request

export type Request = typeof(setmetatable({} :: Proto, {} :: Impl))

function Request.new(request: net.ServeRequest)
	local self = setmetatable({} :: Proto, Request)
	self.body = request.body
	self.headers = request.headers
	self.method = request.method
	self.path = request.path
	self.query = request.query

	return self
end

function Request:get(key: string)
	return self.headers[key]
end

return Request
