local Router = require("Objects/Router")
local Response = require("Objects/Response")
local Request = require("Objects/Request")

local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: () -> App,
	listen: (self: App, port: number, func: () -> ()?) -> (),
	stop: (self: App) -> (),
}

type Proto = {
	router: Router.Router,
	handle: net.ServeHandle,
}

local App: Impl = {} :: Impl
App.__index = App
export type App = typeof(setmetatable({} :: Proto, {} :: Impl))

function App.new()
	local self = setmetatable({} :: Proto, App)
	self.router = Router.new()

	return self
end

function App:listen(port: number, func: (() -> ())?)
	self.handle = net.serve(port, function(req: net.ServeRequest)
		local node = self.router.node:findDescendant(req.path, req.method)
		if not node.handler then
			return {
				body = "route not found",
				status = 404,
				headers = {
					["Content-Type"] = "text/plain",
				},
			} :: net.ServeResponse
		end

		local request = Request.new(req)
		local response = Response.new()

		node.handler(request, response)

		return response:respond()
	end)
end

return App
