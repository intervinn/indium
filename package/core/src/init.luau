local app = require("@core/app")
local router = require("@core/router")
local request = require("@core/request")
local response = require("@core/response")
local handler = require("@core/handler")

local enum = require("@enum/")
local middleware = require("@middleware/")

local Indium = {}

export type App = app.App
export type Router = router.Router
export type Request = request.Request
export type Response = response.Response
export type Handler = handler.Handler
export type Middleware = handler.Middleware
export type NextFunction = handler.NextFunction

Indium.App = app
Indium.Router = router
Indium.Request = request
Indium.Response = response
Indium.Handler = handler

Indium.Enum = enum
Indium.Middleware = middleware

return Indium
