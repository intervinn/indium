--!native
local handler = require("@core/handler")
local node = require("@core/node")
local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: () -> Router,

	route: (self: Router, route: string, handler: handler.Handler, method: net.HttpMethod) -> (),

	post: (self: Router, route: string, handler: handler.Handler) -> (),
	get: (self: Router, route: string, handler: handler.Handler) -> (),
	head: (self: Router, route: string, handler: handler.Handler) -> (),
	options: (self: Router, route: string, handler: handler.Handler) -> (),
	patch: (self: Router, route: string, handler: handler.Handler) -> (),
	put: (self: Router, route: string, handler: handler.Handler) -> (),

	use: (self: Router, func: handler.Middleware) -> (),
	mount: (self: Router, router: Router, prefix: string) -> (),
}

type Proto = {
	node: node.Node,
	middleware: { handler.Middleware },
}

local Router: Impl = {} :: Impl
Router.__index = Router

export type Router = typeof(setmetatable({} :: Proto, {} :: Impl))

function Router.new()
	local self = setmetatable({} :: Proto, Router)
	self.node = node.new({
		children = {},
		dynamic = false,
		middleware = {},
	})
	self.middleware = {}

	local methods = {"GET", "POST", "PUT", "PATCH", "OPTIONS", "HEAD"}
	for _,v in methods do
		self[v:lower()] = function(self, route, handler)
			self:route(route, handler, v)
		end
	end

	return self
end

function Router:route(route, handler, method)
	self.node:add(route, handler, method :: net.HttpMethod, self.middleware)
end

function Router:use(func)
	table.insert(self.middleware, func)
end

function Router:mount(other, prefix)
	other.node.route = prefix:gsub("%/", "")
	table.insert(self.node.children, other.node)
end

return Router
