local Router = require("Objects/Router")

local _ = require("Objects/Context")
local _ = require("@lune/net")

type Impl = {
    __index: Impl,
    new: () -> App,
    listen: (self: App, port: number) -> (),
    stop: (self: App) -> (),
} & Router.RouterMethodImpl

type Proto = {
    router: Router.Router
}

local App: Impl = {} :: Impl
App.__index = App
export type App = typeof(setmetatable({} :: Proto, {} :: Impl))

function App.new()
    local self = setmetatable({} :: Proto, App)
    self.router = Router.new()

    return self
end

function App:listen(port: number)
    print("this is the part where server listens")
end

return App