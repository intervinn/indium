local App = require("@Classes/App")
local Router = require("@Classes/Router")
local Request = require("@Classes/Request")
local Response = require("@Classes/Response")
local Handler = require("@Classes/Handler")

local Status = require("@Enums/Status")

local Indium = {}

export type Response = Response.Response
Indium.Response = Response

export type Request = Request.Request
Indium.Request = Request

export type App = App.App
Indium.App = App

export type Router = Router.Router
Indium.Router = Router

Indium.Status = Status

export type Handler = Handler.Handler
export type Middleware = Handler.Middleware
export type NextFunction = Handler.NextFunction

return Indium