local net = require("@lune/net")

type Proto = {
    headers: {[string]: string},
    body: string,
    status: number,
}

type Impl = {
    __index: Impl,
    new: (req: net.ServeRequest) -> Context
}

local Context: Impl = {} :: Impl
Context.__index = Context

export type Context = typeof(setmetatable({} :: Proto, {} :: Impl))

function Context.new(req: net.ServeRequest)
    local self = setmetatable({} :: Proto, Context)
    
    self.headers = {
        ["Content-Type"] = "text/plain"
    }
    self.body = "Route not found"
    self.status = 404

    return self
end

return Context