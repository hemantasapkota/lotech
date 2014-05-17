images = lt.LoadImages({
  "bg1",
  "bg2",
  "ground",
  "block",
})

fontImages = lt.LoadImages({
    {font = "font", glyphs = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890.,-&?!%@/:()'=[]"}
  },
  "linear",
  "linear")

font = fontImages.font

function makeBox(body, hw, hh)
  return body:Polygon{-hw, hh, -hw, -hh, hw, -hh, hw, hh}
end

function makeBlock(a, b)
    local w, h = 0.3, 0.28
    local block_body = world:Body({type="kinematic", x=a, y=b})
    local block_body_fixture = makeBox(block_body, w, h)

    block_body_fixture.block = true
    block_body.child = images.block:Scale(0.2)

    return block_body
end
