--!native
local handler = require("@core/handler")
local std = require("@util/std")

type Impl = {
	__index: Impl,
	new: (params: Proto) -> Node,
	findDescendant: (self: Node, route: string, method: std.HttpMethod?) -> (Node?, { [string]: string }),
	findChild: (self: Node, route: string, method: std.HttpMethod?) -> Node?,
	add: (
		self: Node,
		route: string,
		handler: handler.Handler,
		method: std.HttpMethod,
		middleware: { handler.Middleware }
	) -> (),
}

type Proto = {
	method: std.HttpMethod?,
	handler: handler.Handler?,
	route: string?,
	children: { Node },
	middleware: { handler.Middleware },
	dynamic: boolean,
}

local Node: Impl = {} :: Impl
Node.__index = Node

export type Node = typeof(setmetatable({} :: Proto, {} :: Impl))

function Node.new(params: Proto)
	local self = setmetatable(params :: Proto, Node)

	return self
end

function Node:findChild(route: string, method: std.HttpMethod?): Node?
	for _, v in self.children do
		if method and v.method and method ~= v.method then
			continue
		end

		if v.route == route then
			return v
		end
	end

	--[[ 
		if no static routes available..
		search for first available dynamic route
	]]

	for _, v in self.children do
		if not v.route then
			continue
		end

		if v.dynamic then
			if method and v.method and method ~= v.method then
				continue
			end
			return v
		end
	end

	return nil
end

function Node:findDescendant(route: string, method: std.HttpMethod?): (Node?, { [string]: string })
	local res: Node = self :: Node
	local tmp: Node?
	local params = {}

	for str in route:gmatch("([^/]+)") do
		tmp = res:findChild(str, method)

		if tmp then
			res = tmp
			tmp = nil
		else
			return nil, {}
		end

		if res.dynamic and res.route then
			params[res.route:sub(2)] = str
		end
	end

	return res, params
end

function Node:add(route: string, handler: handler.Handler, method: std.HttpMethod, middleware: { handler.Middleware })
	local scope: Node = self
	local pieces = {} :: { string }
	for str in route:gmatch("([^/]+)") do
		table.insert(pieces, str)
	end

	if #pieces == 0 then
		self.method = method
		self.handler = handler
		self.middleware = middleware
		return
	end

	for i, v in pieces do
		if i == #pieces then
			table.insert(
				scope.children,
				Node.new({
					route = v,
					handler = handler,
					middleware = middleware,
					children = {},
					dynamic = (v:sub(1, 1) == ":"),
				})
			)
			return
		end

		local node = scope:findChild(v) :: any
		if not node then
			node = Node.new({
				route = v,
				dynamic = (v:sub(1, 1) == ":"),
				children = {},
				middleware = middleware,
			})
			table.insert(scope.children, node)
		end
		scope = node
	end
end

return Node
