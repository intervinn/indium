local App = require("Classes/App")

local app = App.new()

app:post("/", function()
    print("hello, world!")
end)

app:listen(8080)


print(app)