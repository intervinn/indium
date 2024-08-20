local Handler = require("Handler")
local Node = require("@Classes/Node")
local net = require("@lune/net")

type Impl = {
	__index: Impl,
	new: () -> Router,

	route: (self: Router, route: string, handler: Handler.Handler, method: net.HttpMethod) -> (),

	post: (self: Router, route: string, handler: Handler.Handler) -> (),
	get: (self: Router, route: string, handler: Handler.Handler) -> (),
	head: (self: Router, route: string, handler: Handler.Handler) -> (),
	options: (self: Router, route: string, handler: Handler.Handler) -> (),
	patch: (self: Router, route: string, handler: Handler.Handler) -> (),
	put: (self: Router, route: string, handler: Handler.Handler) -> (),

	use: (self: Router, func: Handler.Middleware) -> (),
	mount: (self: Router, router: Router, prefix: string) -> ()
}

type Proto = {
	node: Node.Node,
	middleware: {Handler.Middleware}
}

local Router: Impl = {} :: Impl
Router.__index = Router

export type Router = typeof(setmetatable({} :: Proto, {} :: Impl))

function Router.new()
	local self = setmetatable({} :: Proto, Router)
	self.node = Node.new()
	self.middleware = {}
	return self
end

function Router:route(route: string, handler: Handler.Handler, method: net.HttpMethod)
	self.node:add(route, handler, method, self.middleware)
end

function Router:get(route: string, handler: Handler.Handler)
	self:route(route, handler, "GET")
end

function Router:head(route: string, handler: Handler.Handler)
	self:route(route, handler, "HEAD")
end

function Router:options(route: string, handler: Handler.Handler)
	self:route(route, handler, "OPTIONS")
end

function Router:patch(route: string, handler: Handler.Handler)
	self:route(route, handler, "PATCH")
end

function Router:put(route: string, handler: Handler.Handler)
	self:route(route, handler, "PUT")
end

function Router:use(func: Handler.Middleware)
	table.insert(self.middleware, func)
end

function Router:mount(other: Router, prefix: string)
	other.node.route = prefix
	table.insert(self.node.children, other.node)
end

return Router
