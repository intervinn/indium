local request = require("@core/request")
local response = require("@core/response")

export type NextFunction = () -> ()

export type Handler = (req: request.Request, res: response.Response) -> ()
export type Middleware = (req: request.Request, res: response.Response, NextFunction) -> ()

return {}
