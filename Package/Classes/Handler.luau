local Request = require("@Classes/Request")
local Response = require("@Classes/Response")

export type NextFunction = () -> ()

export type Handler = (req: Request.Request, res: Response.Response) -> ()
export type Middleware = (req: Request.Request, res: Response.Response, NextFunction) -> ()

return nil
