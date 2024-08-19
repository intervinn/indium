local Handler = require("Handler")
local Node = require("../Internal/Node")
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
}

type Proto = {
    node: Node.Node
}

local Router: Impl = {} :: Impl
Router.__index = Router

export type Router = typeof(setmetatable({} :: Proto, {} :: Impl))

function Router.new()
    local self = setmetatable({} :: Proto, Router)
    self.node = Node.new()
    return self
end

function Router:route(route: string, handler: Handler.Handler, method: net.HttpMethod)
    self.node:add(route, handler, method)
end

function Router:get(route: string, handler: Handler.Handler)
    self.node:add(route, handler, "GET")
end

function Router:head(route: string, handler: Handler.Handler)
    self.node:add(route, handler, "HEAD")
end

function Router:options(route: string, handler: Handler.Handler)
    self.node:add(route, handler, "OPTIONS")
end

function Router:patch(route: string, handler: Handler.Handler)
    self.node:add(route, handler, "PATCH")
end

function Router:put(route: string, handler: Handler.Handler)
    self.node:add(route, handler, "PUT")
end

return Router