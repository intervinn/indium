local Request = require("Request")
local Response = require("Response")

export type Handler = (req: Request.Request, res: Response.Response) -> ()

return nil